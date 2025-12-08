class TestSuiteRunFinish
  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def process
    @test_suite_run.check_test_case_run_integrity!
    TestSuiteRunLinkComponent.refresh(@test_suite_run)
    GitHubCheckRun.find_by(test_suite_run: @test_suite_run)&.finish!
  end
end
