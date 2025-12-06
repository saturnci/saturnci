class TestSuiteRun < ApplicationRecord
  NOTIFICATION_FEATURE_LAUNCH_DATETIME = "2025-08-11 22:00:00 UTC"
  
  acts_as_paranoid
  belongs_to :repository
  belongs_to :project, foreign_key: "repository_id"
  has_many :runs, foreign_key: "build_id", dependent: :destroy
  alias_method :tasks, :runs
  has_many :test_case_runs, through: :runs
  alias_attribute :project_id, :repository_id
  
  has_many :test_suite_run_result_notifications, dependent: :destroy
  scope :needing_notification, -> do
    left_joins(:test_suite_run_result_notifications)
      .where(test_suite_run_result_notifications: { id: nil })
      .where("test_suite_runs.created_at > ?", NOTIFICATION_FEATURE_LAUNCH_DATETIME)
      .where.not(cached_status: ["Running", "Not Started"])
  end

  after_initialize do
    self.seed ||= rand(10000)
  end

  def cache_status
    status = calculated_status
    Rails.cache.write(status_cache_key, status)
    update!(cached_status: status)
  end

  def start!
    return unless repository.active

    case repository.worker_architecture.slug
    when WorkerArchitecture::TERRA_SLUG
      Terra.start_test_suite_run(self)
    when WorkerArchitecture::NOVA_SLUG
      Nova.start_test_suite_run(self)
    end
  end

  def cancel!
    transaction do
      runs.each(&:cancel!)
    end
  end

  def status
    Rails.cache.fetch(status_cache_key) do
      calculated_status
    end
  end

  def status_with_counts
    case status
    when "Passed"
      "Passed (#{dry_run_example_count})"
    when "Failed"
      "Failed (#{test_case_runs.failed.count}/#{dry_run_example_count})"
    else
      status
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
    channel = [repository, repository.user, "test_suite_runs"]

    broadcast_remove_to(
      channel,
      target: ActionView::RecordIdentifier.dom_id(self)
    )

    broadcast_prepend_to(
      channel,
      target: "test-suite-run-list",
      partial: "test_suite_runs/test_suite_run_link",
      locals: { build: self, active_build: nil }
    )
  end

  def check_test_case_run_integrity!
    if test_case_runs.count != dry_run_example_count
      raise "Test case count mismatch: expected #{dry_run_example_count}, got #{test_case_runs.count}"
    end
  end

  def status_cache_key
    "test_case_run/#{id}/status"
  end
end
