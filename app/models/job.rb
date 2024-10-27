class Job < ApplicationRecord
  belongs_to :build, touch: true
  has_many :job_events, dependent: :destroy
  has_one :charge

  alias_attribute :started_at, :created_at
  default_scope -> { order("order_index") }

  scope :running, -> do
    unscoped.joins(:build)
      .where.not(id: Job.finished.select(:id))
      .order("builds.created_at DESC")
  end

  scope :finished, -> do
    where.not(exit_code: nil)
  end

  def name
    "Job #{order_index}"
  end

  def start!
    ActiveRecord::Base.transaction do
      job_events.create!(type: :job_machine_requested)
      job_machine_request.create!
    end
  end

  def cancel!
    ActiveRecord::Base.transaction do
      job_events.create!(type: :job_cancelled)
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
    job_events.job_cancelled.any?
  end

  def job_machine_request
    JobMachineRequest.new(
      job: self,
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
    ActiveRecord::Base.transaction do
      job_events.create!(type: "job_finished")
      update!(exit_code: parsed_exit_code || 1)

      if Set.new(build.jobs) == Set.new(build.jobs.finished)
        build.update!(cached_status: build.calculated_status)
      end

      create_charge!(
        job_duration: duration,
        rate: Rails.configuration.charge_rate
      )
    end

    self
  end

  private

  def parsed_exit_code
    return nil unless test_output.present?
    match = test_output.match(/COMMAND_EXIT_CODE="(\d+)"/)
    match ? match[1].to_i : nil
  end

  def ended_at
    job_finished_event&.created_at
  end

  def job_finished_event
    job_events.job_finished.first
  end
end
