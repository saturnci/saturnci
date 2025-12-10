class Task < ApplicationRecord
  acts_as_paranoid
  self.table_name = "tasks"
  alias_attribute :build_id, :test_suite_run_id
  belongs_to :build, foreign_key: "test_suite_run_id", touch: true
  belongs_to :test_suite_run, touch: true
  has_many :test_case_runs, dependent: :destroy
  has_many :task_events, dependent: :destroy
  alias_method :run_events, :task_events
  has_one :charge
  has_one :runner_system_log
  has_one :rsa_key, class_name: "Cloud::RSAKey", foreign_key: "run_id"
  has_one :task_worker
  alias_method :run_worker, :task_worker
  has_one :worker_assignment, dependent: :destroy
  has_one :worker, through: :worker_assignment, source: :worker
  alias_attribute :started_at, :created_at
  delegate :project, to: :build
  delegate :repository, to: :test_suite_run

  scope :sorted, -> do
    order("tasks.order_index")
  end

  scope :finished, -> do
    joins(:test_suite_run).where.not(exit_code: nil)
  end

  scope :not_finished, -> do
    joins(:test_suite_run).where(exit_code: nil)
  end

  scope :running, -> do
    not_finished.order("test_suite_runs.created_at desc, tasks.order_index asc")
  end

  scope :unassigned, -> do
    not_finished
      .left_joins(:worker_assignment)
      .where(worker_assignments: { task_id: nil })
      .where(exit_code: nil)
  end

  def name
    "Worker #{order_index}"
  end

  def cancel!
    transaction do
      delete_runner
      run_events.create!(type: :task_cancelled)
      update!(test_output: "Run cancelled")
      finish!
    end
  end

  def status
    return "Running" if !finished?
    return "Passed" if finished? && passed?
    return "Cancelled" if cancelled?
    "Failed"
  end

  def finished?
    self.class.finished.include?(self)
  end

  def passed?
    exit_code == 0
  end

  def failed?
    finished? && !passed?
  end

  def cancelled?
    run_events.task_cancelled.any?
  end

  def provision_worker
    worker_agent_script = WorkerAgentScript.new(self, test_suite_run.project.github_account.github_installation_id)

    worker = Worker.provision(
      client: DropletKitClientFactory.client,
      user_data: worker_agent_script.content,
    )

    RunWorker.create!(worker:, run: self)
  end

  alias_method :assign_worker, :provision_worker

  def delete_runner
    return unless worker.present?
    Nova.delete_k8s_job(worker.name)
  rescue StandardError => e
    Rails.logger.error "Error deleting runner: #{e.message}"
  end

  def duration
    return unless ended_at.present?
    (ended_at - started_at).round
  end

  def finish!
    transaction do
      run_events.create!(type: "task_finished")
      update!(exit_code: parsed_exit_code || 1)

      create_charge!(
        run_duration: duration,
        rate: Rails.configuration.charge_rate
      )
    end

    self
  end

  def system_logs
    runner_system_log&.content
  end

  private

  def parsed_exit_code
    return nil unless json_output.present?

    summary = JSON.parse(json_output)["summary"]
    return nil unless summary

    summary["failure_count"].to_i.zero? ? 0 : 1
  rescue JSON::ParserError
    nil
  end

  def ended_at
    task_finished_event&.created_at
  end

  def task_finished_event
    run_events.task_finished.first
  end
end
