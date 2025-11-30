class Worker < ApplicationRecord
  self.table_name = "workers"

  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  belongs_to :access_token
  has_many :worker_events, inverse_of: :worker, dependent: :destroy
  has_one :run_test_runner
  has_one :test_runner_assignment, class_name: "WorkerAssignment", inverse_of: :worker, dependent: :destroy
  has_one :run, through: :test_runner_assignment
  before_destroy :deprovision

  scope :unassigned, -> do
    left_joins(:test_runner_assignment).where(worker_assignments: { run_id: nil })
  end

  scope :available, -> do
    unassigned.joins(:worker_events)
      .where(worker_events: { type: :ready_signal_received })
      .where("worker_events.created_at = (
        SELECT MAX(created_at) FROM worker_events
        WHERE worker_events.worker_id = workers.id
      )")
  end

  scope :running, -> do
    joins(:worker_events)
      .where(worker_events: { type: WorkerEvent.types[:assignment_acknowledged] })
  end

  scope :error, -> do
    joins(:worker_events)
      .where(worker_events: { type: WorkerEvent.types[:error] })
  end

  scope :recently_assigned, -> do
    joins(:test_runner_assignment)
      .where("worker_assignments.created_at > ?", 10.seconds.ago)
  end

  def self.provision
    access_token = AccessToken.create!
    name = "tr-#{SecureRandom.uuid[0..7]}-#{SillyName.random.gsub(/ /, "-")}"

    create!(name:, access_token:).tap do |test_runner|
      create_vm(test_runner, name)
      test_runner.worker_events.create!(type: :provision_request_sent)
    end
  end

  def self.create_vm(worker, name)
    worker_droplet_specification = WorkerDropletSpecification.new(
      worker:,
      name:,
    )

    droplet = worker_droplet_specification.execute

    worker.update!(
      rsa_key: worker_droplet_specification.rsa_key,
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
    worker_events.order("created_at desc").first
  end

  def as_json(options = {})
    super(options).merge(
      status:,
      run_id: run&.id,
      commit_message: run&.test_suite_run&.commit_message,
      repository_name: run&.repository&.name,
    )
  end

  def assign(run)
    transaction do
      worker_events.create!(type: :assignment_made)
      TestRunnerAssignment.create!(worker: self, run:)
    end
  end
end
