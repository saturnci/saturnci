class TestCaseRunListComponent < ViewComponent::Base
  attr_reader :build, :active_test_case_run
  LIMIT = 30

  def initialize(build:, active_test_case_run:)
    @build = build
    @active_test_case_run = active_test_case_run
  end

  def test_case_runs
    TestCaseRun.failed_first(build.test_case_runs)[0..(LIMIT - 1)]
  end

  def test_case_run_count
    build.test_case_runs.size
  end

  def failed_test_case_run_count
    build.test_case_runs.select { |tcr| tcr.status == "failed" }.size
  end
end
