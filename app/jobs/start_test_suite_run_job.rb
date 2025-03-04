class StartTestSuiteRunJob < ApplicationJob
  queue_as :default

  def perform(test_suite_run_id)
    test_suite_run = TestSuiteRun.find(test_suite_run_id)
    test_suite_run.start!
    TestSuiteRunLinkComponent.refresh(test_suite_run)
  end
end
