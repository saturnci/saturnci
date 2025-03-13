class StartTestSuiteRunJob < ApplicationJob
  RETRY_INTERVAL_IN_SECONDS = 2
  queue_as :default

  def perform(test_suite_run_id)
    test_suite_run = TestSuiteRun.find(test_suite_run_id)
    test_suite_run.assign_test_runners
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn "Run #{run_id} not found. Retrying in #{RETRY_INTERVAL_IN_SECONDS} seconds..."
    retry_job wait: RETRY_INTERVAL_IN_SECONDS.seconds if executions < 10
  end
end
