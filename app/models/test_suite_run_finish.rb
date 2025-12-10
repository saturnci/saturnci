class TestSuiteRunFinish
  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def process
    @test_suite_run.check_test_case_run_integrity!
    @test_suite_run.cache_status
    TestSuiteRunLinkComponent.refresh(@test_suite_run)
    GitHubCheckRun.find_by(test_suite_run: @test_suite_run)&.finish!

    failed_test_case_runs = @test_suite_run.test_case_runs.failed
    return unless failed_test_case_runs.any?

    rerun_test_suite_run = TestSuiteRun.create!(
      repository: @test_suite_run.repository,
      branch_name: @test_suite_run.branch_name,
      commit_hash: @test_suite_run.commit_hash,
      commit_message: @test_suite_run.commit_message,
      author_name: @test_suite_run.author_name,
      dry_run_example_count: failed_test_case_runs.count,
      started_by_user: @test_suite_run.started_by_user
    )

    FailureRerun.create!(
      original_test_suite_run: @test_suite_run,
      test_suite_run: rerun_test_suite_run
    )

    task = Task.create!(test_suite_run: rerun_test_suite_run, order_index: 1)
    Nova.start_test_suite_run(rerun_test_suite_run, [task])
    rerun_test_suite_run.broadcast
    rerun_test_suite_run
  end
end
