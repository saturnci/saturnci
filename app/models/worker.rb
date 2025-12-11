class Worker < ApplicationRecord
  self.table_name = "workers"

  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  belongs_to :access_token
  has_many :worker_events, inverse_of: :worker, dependent: :destroy
  has_one :run_worker
  has_one :worker_assignment, inverse_of: :worker, dependent: :destroy
  has_one :task, through: :worker_assignment
  alias_method :run, :task

  scope :unassigned, -> do
    left_joins(:worker_assignment).where(worker_assignments: { task_id: nil })
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
    joins(:worker_assignment)
      .where("worker_assignments.created_at > ?", 10.seconds.ago)
  end

  def status
    return "" if most_recent_event.blank?

    {
      "ready_signal_received" => "Available",
      "assignment_made" => "Assigned",
      "assignment_acknowledged" => "Running",
      "error" => "Error",
      "task_finished" => "Finished",
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
      WorkerAssignment.create!(worker: self, run:)
    end
  end
end
