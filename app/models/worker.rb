class Worker < ApplicationRecord
  self.table_name = "workers"

  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  belongs_to :access_token
  belongs_to :task, optional: true
  has_many :worker_events, inverse_of: :worker, dependent: :destroy
  has_one :run_worker
  alias_method :run, :task

  def status
    return "" if most_recent_event.blank?

    {
      "ready_signal_received" => "Available",
      "error" => "Error",
      "task_finished" => "Finished",
    }[most_recent_event.name]
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

end
