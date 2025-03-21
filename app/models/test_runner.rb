class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  has_many :test_runner_events, dependent: :destroy
  has_one :run_test_runner
  has_one :test_runner_assignment, dependent: :destroy
  has_one :run, through: :test_runner_assignment
  before_destroy :deprovision

  scope :unassigned, -> do
    left_joins(:test_runner_assignment).where(test_runner_assignments: { run_id: nil })
  end

  scope :available, -> do
    unassigned.joins(:test_runner_events)
      .where(test_runner_events: { type: :ready_signal_received })
      .where("test_runner_events.created_at = (
        SELECT MAX(created_at) FROM test_runner_events
        WHERE test_runner_events.test_runner_id = test_runners.id
      )")
  end

  scope :running, -> do
    joins(:test_runner_events)
      .where(test_runner_events: { type: TestRunnerEvent.types[:assignment_acknowledged] })
  end

  scope :error, -> do
    joins(:test_runner_events)
      .where(test_runner_events: { type: TestRunnerEvent.types[:error] })
  end

  scope :recently_assigned, -> do
    joins(:test_runner_assignment)
      .where("test_runner_assignments.created_at > ?", 10.seconds.ago)
  end

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
end
