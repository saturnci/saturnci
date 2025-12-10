class TestSuiteRunStatusComponent < ViewComponent::Base
  attr_reader :test_suite_run

  def initialize(test_suite_run:)
    @test_suite_run = test_suite_run
  end

  private

  def passed_count
    test_suite_run.test_case_runs.passed.count
  end

  def failed_count
    test_suite_run.test_case_runs.failed.count
  end

  def total_count
    test_suite_run.test_case_runs.count
  end
end
