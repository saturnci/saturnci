class Run < ApplicationRecord
  self.table_name = "runs"
  belongs_to :build, touch: true
  has_many :run_events, dependent: :destroy
  has_one :charge, foreign_key: "run_id"

  alias_attribute :started_at, :created_at
  default_scope -> { order("order_index") }

  scope :running, -> do
    unscoped.joins(:build)
      .where.not(id: Run.finished.select(:id))
      .order("builds.created_at DESC")
  end

  scope :finished, -> do
    where.not(exit_code: nil)
  end

  def name
    "Run #{order_index}"
  end

  def start!
    transaction do
      run_events.create!(type: :runner_requested)
      runner_request.create!
    end
  end

  def cancel!
    transaction do
      delete_job_machine
      run_events.create!(type: :job_cancelled)
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
    !passed?
  end

  def cancelled?
    run_events.job_cancelled.any?
  end

  def runner_request
    RunnerRequest.new(
      run: self,
      github_installation_id: build.project.saturn_installation.github_installation_id
    )
  end

  def delete_job_machine
    client = DropletKit::Client.new(access_token: ENV['DIGITALOCEAN_ACCESS_TOKEN'])
    client.droplets.delete(id: job_machine_id)
  end

  def duration
    return unless ended_at.present?
    (ended_at - started_at).round
  end

  def finish!
    transaction do
      run_events.create!(type: "job_finished")
      update!(exit_code: parsed_exit_code || 1)

      if Set.new(build.runs) == Set.new(build.runs.finished)
        build.update!(cached_status: build.calculated_status)
      end

      create_charge!(
        run_duration: duration,
        rate: Rails.configuration.charge_rate
      )
    end

    self
  end

  private

  def parsed_exit_code
    return nil unless test_output.present?
    match = test_output.match(/COMMAND_EXIT_CODE="?(\d+)"?/)
    match ? match[1].to_i : nil
  end

  def ended_at
    job_finished_event&.created_at
  end

  def job_finished_event
    run_events.job_finished.first
  end
end
