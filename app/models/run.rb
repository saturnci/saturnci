class Run < ApplicationRecord
  acts_as_paranoid
  self.table_name = "tasks"
  belongs_to :build, touch: true
  belongs_to :test_suite_run, class_name: "TestSuiteRun", foreign_key: "build_id", touch: true
  has_many :test_case_runs, dependent: :destroy
  has_many :run_events, dependent: :destroy
  has_one :charge, foreign_key: "run_id"
  has_one :runner_system_log
  has_one :rsa_key, class_name: "Cloud::RSAKey"
  has_one :run_worker
  has_one :worker_assignment, dependent: :destroy
  has_one :worker, through: :worker_assignment, source: :worker
  alias_attribute :started_at, :created_at
  delegate :project, to: :build
  delegate :repository, to: :test_suite_run
  after_save { test_suite_run.cache_status }

  scope :sorted, -> do
    order("tasks.order_index")
  end

  scope :finished, -> do
    joins(:build).where.not(exit_code: nil)
  end

  scope :not_finished, -> do
    joins(:build).where(exit_code: nil)
  end

  scope :running, -> do
    not_finished.order("test_suite_runs.created_at desc, tasks.order_index asc")
  end

  scope :unassigned, -> do
    not_finished
      .left_joins(:worker_assignment)
      .where(worker_assignments: { run_id: nil })
      .where(exit_code: nil)
  end

  def name
    "Worker #{order_index}"
  end

  def cancel!
    transaction do
      delete_runner
      run_events.create!(type: :run_cancelled)
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
    run_events.run_cancelled.any?
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
    raise "cloud_id missing" unless worker.cloud_id.present?
    client = DropletKit::Client.new(access_token: ENV['DIGITALOCEAN_ACCESS_TOKEN'])
    client.droplets.delete(id: worker.cloud_id)
  rescue DropletKit::Error => e
    Rails.logger.error "Error deleting runner: #{e.message}"
  end

  def duration
    return unless ended_at.present?
    (ended_at - started_at).round
  end

  def finish!
    transaction do
      run_events.create!(type: "run_finished")
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
    return nil unless test_output.present?
    match = test_output.match(/COMMAND_EXIT_CODE="?(\d+)"?/)
    match ? match[1].to_i : nil
  end

  def ended_at
    run_finished_event&.created_at
  end

  def run_finished_event
    run_events.run_finished.first
  end
end
