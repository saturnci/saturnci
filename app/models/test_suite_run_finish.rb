class TestSuiteRunFinish
  RETRY_LIMIT = 3

  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def process
    @test_suite_run.check_test_case_run_integrity!
    TestSuiteRunLinkComponent.refresh(@test_suite_run)
    GitHubCheckRun.find_by(test_suite_run: @test_suite_run)&.finish!

    start_rerun if @test_suite_run.test_case_runs.failed.any?
  end

  private

  def start_rerun
    return if retry_depth >= RETRY_LIMIT
    rerun_test_suite_run = TestSuiteRun.create!(
      repository: @test_suite_run.repository,
      branch_name: @test_suite_run.branch_name,
      commit_hash: @test_suite_run.commit_hash,
      commit_message: @test_suite_run.commit_message,
      author_name: @test_suite_run.author_name
    )

    FailureRerun.create!(
      original_test_suite_run: @test_suite_run,
      test_suite_run: rerun_test_suite_run
    )

    rerun_test_suite_run.start!
    rerun_test_suite_run.broadcast
    rerun_test_suite_run
  end

  def retry_depth
    depth = 0
    current = @test_suite_run

    while (failure_rerun = FailureRerun.find_by(test_suite_run: current))
      depth += 1
      current = failure_rerun.original_test_suite_run
    end

    depth
  end
end
