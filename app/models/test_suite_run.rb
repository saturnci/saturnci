class TestSuiteRun < ApplicationRecord
  acts_as_paranoid
  belongs_to :project
  has_many :runs, foreign_key: "build_id"
  has_many :test_case_runs, through: :runs

  after_initialize do
    self.seed ||= rand(10000)
  end

  def cache_status
    status = calculated_status
    Rails.cache.write(status_cache_key, status)
    update!(cached_status: status)
  end

  def start!
    return unless project.active

    transaction do
      save!

      runs_to_use.each do |run|
        run.start!
      end
    end
  end

  def runs_to_use
    project.concurrency.times.map do |i|
      Run.create!(test_suite_run: self, order_index: i + 1)
    end
  end

  def cancel!
    transaction do
      runs.each(&:cancel!)
    end
  end

  def passed?
    status == "Passed"
  end

  def status
    Rails.cache.fetch(status_cache_key) do
      calculated_status
    end
  end

  def calculated_status
    run_statuses = runs.reload.map(&:status)

    return "Not Started" if run_statuses.empty?
    return "Running" if run_statuses.any?("Running")
    return "Failed" if run_statuses.any?("Failed")
    return "Cancelled" if run_statuses.any?("Cancelled")
    return "Passed" if run_statuses.all?("Passed")
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

  def started_at
    runs.map(&:started_at).min
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
      [project, project.user, "builds"],
      target: "test-suite-run-list",
      partial: "test_suite_runs/test_suite_run_link",
      locals: { build: self, active_build: nil }
    )
  end

  def status_cache_key
    "test_case_run/#{id}/status"
  end
end
