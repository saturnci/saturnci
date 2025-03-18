class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  has_many :test_runner_events, dependent: :destroy
  has_one :run_test_runner
  has_one :test_runner_assignment, dependent: :destroy
  has_one :run, through: :test_runner_assignment
  before_destroy :deprovision

  scope :unassigned, -> {
    left_joins(:test_runner_assignment).where(test_runner_assignments: { run_id: nil })
  }

  scope :available, -> {
    unassigned.joins(:test_runner_events)
      .where(test_runner_events: { type: :ready_signal_received })
      .where("test_runner_events.created_at = (
        SELECT MAX(created_at) FROM test_runner_events
        WHERE test_runner_events.test_runner_id = test_runners.id
      )")
  }

  def self.provision
    name = "tr-#{SecureRandom.uuid[0..7]}-#{SillyName.random.gsub(/ /, "-")}"

    create!(name:).tap do |test_runner|
      create_vm(test_runner, name)
      test_runner.test_runner_events.create!(type: :provision_request_sent)
    end
  end

  def self.create_vm(test_runner, name)
    test_runner_droplet_specification = TestRunnerDropletSpecification.new(
      test_runner_id: test_runner.id,
      name:,
    )

    droplet = test_runner_droplet_specification.execute

    test_runner.update!(
      rsa_key: test_runner_droplet_specification.rsa_key,
      cloud_id: droplet.id
    )
  end

  def deprovision(client = DropletKitClientFactory.client)
    client.droplets.delete(id: cloud_id)
  rescue DropletKit::Error => e
    Rails.logger.error "Error deleting test runner: #{e.message}"
  end

  def status
    return "" if most_recent_event.blank?

    {
      "provision_request_sent" => "Provisioning",
      "ready_signal_received" => "Available",
      "assignment_made" => "Assigned",
      "assignment_acknowledged" => "Running",
      "error" => "Error",
      "test_run_finished" => "Finished",
    }[most_recent_event.type]
  end

  def most_recent_event
    test_runner_events.order("created_at desc").first
  end

  def as_json(options = {})
    super(options).merge(
      status:,
      run_id: run&.id,
      commit_message: run&.test_suite_run&.commit_message,
    )
  end

  def assign(run)
    transaction do
      test_runner_events.create!(type: :assignment_made)
      TestRunnerAssignment.create!(test_runner: self, run:)
    end
  end

  def self.supervise
    puts "-" * 80

    available_test_runners = nil
    unassigned_test_runners = nil

    unassigned_runs = Run.unassigned.where("runs.created_at > ?", 1.day.ago)
    puts "Unassigned runs: #{unassigned_runs.count}"

    ActiveRecord::Base.uncached do
      available_test_runners = TestRunner.available.to_a.shuffle
      unassigned_test_runners = TestRunner.unassigned
    end
    puts "Available test runners: #{available_test_runners.count}"
    puts "Unassigned test runners: #{unassigned_test_runners.count}"

    if unassigned_test_runners.count < unassigned_runs.count
      number_of_needed_test_runners = unassigned_runs.count - unassigned_test_runners.count
      puts "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    end

    unassigned_runs.each do |run|
      break if available_test_runners.empty?
      test_runner = available_test_runners.shift
      puts "Assigning #{test_runner.name} to #{run.id}"
      test_runner.assign(run)
    end

    test_runner_pool_size = ENV.fetch("TEST_RUNNER_POOL_SIZE", 10).to_i
    puts "Test runner pool size: #{test_runner_pool_size}"

    if unassigned_test_runners.count < test_runner_pool_size
      number_of_needed_test_runners = test_runner_pool_size - unassigned_test_runners.count
      puts "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    end
  end
end
