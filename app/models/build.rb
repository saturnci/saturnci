class Build < ApplicationRecord
  NUMBER_OF_CONCURRENT_JOBS = 2
  belongs_to :project
  has_many :jobs
  acts_as_paranoid

  after_initialize do
    self.seed ||= rand(10000)
  end

  def start!
    return unless project.active

    transaction do
      save!

      jobs_to_use.each do |job|
        job.save!
        job.start!
      end
    end
  end

  def cancel!
    transaction do
      jobs.each(&:cancel!)
    end
  end

  def status
    if cached_status != calculated_status
      update!(cached_status: calculated_status)
    end

    cached_status
  end

  def calculated_status
    return "Not Started" if jobs.empty?
    return "Running" if jobs.any? { |job| job.status == "Running" } || jobs.empty?
    return "Failed" if jobs.any? { |job| job.status == "Failed" }
    return "Cancelled" if jobs.any? { |job| job.status == "Cancelled" }
    return "Passed" if jobs.all? { |job| job.status == "Passed" }
    "Failed"
  end

  def jobs_to_use
    NUMBER_OF_CONCURRENT_JOBS.times.map do |i|
      Job.new(build: self, order_index: i + 1)
    end
  end

  def duration_formatted
    return unless duration.present?
    minutes = (duration / 60).floor
    seconds = (duration % 60).floor
    "#{minutes}m #{seconds}s"
  end

  def duration
    job_durations = jobs.map(&:duration)
    return nil if job_durations.any?(nil)
    job_durations.max
  end

  def delete_job_machines
    jobs.each(&:delete_job_machine)
  end
end
