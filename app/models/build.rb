class Build < ApplicationRecord
  acts_as_paranoid
  belongs_to :project
  has_many :jobs
  has_many :runs
  has_many :test_case_runs, through: :runs

  after_initialize do
    self.seed ||= rand(10000)
  end

  def start!
    return unless project.active

    transaction do
      save!

      runs_to_use.each do |run|
        run.save!
        run.start!
      end
    end
  end

  def runs_to_use
    project.concurrency.times.map do |i|
      Run.new(build: self, order_index: i + 1)
    end
  end

  def cancel!
    transaction do
      runs.each(&:cancel!)
    end
  end

  def status
    if cached_status != calculated_status
      update!(cached_status: calculated_status)
    end

    cached_status
  end

  def calculated_status
    return "Not Started" if runs.empty?
    return "Running" if runs.any? { |run| run.status == "Running" } || runs.empty?
    return "Failed" if runs.any? { |run| run.status == "Failed" }
    return "Cancelled" if runs.any? { |run| run.status == "Cancelled" }
    return "Passed" if runs.all? { |run| run.status == "Passed" }
    "Failed"
  end

  def finished?
    cache_key = "build/#{id}/finished"
    return Rails.cache.read(cache_key) if Rails.cache.exist?(cache_key)

    if status != "Running" && status != "Not Started"
      Rails.cache.write(cache_key, true)
      return true
    end

    false
  end

  def duration_formatted
    return unless duration.present?
    minutes = (duration / 60).floor
    seconds = (duration % 60).floor
    "#{minutes}m #{seconds}s"
  end

  def duration
    run_durations = runs.map(&:duration)
    return nil if run_durations.any?(nil)
    run_durations.max
  end

  def delete_runners
    runs.each(&:delete_runner)
  end

  def broadcast
    broadcast_remove_to(
      [project.user, "builds"],
      target: ActionView::RecordIdentifier.dom_id(self)
    )

    broadcast_prepend_to(
      [project.user, "builds"],
      target: "build-list",
      partial: "builds/build_link",
      locals: { build: self, active_build: nil }
    )
  end
end
