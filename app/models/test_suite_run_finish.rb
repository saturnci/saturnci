class TestSuiteRunFinish
  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def process
    @test_suite_run.check_test_case_run_integrity!
    TestSuiteRunLinkComponent.refresh(@test_suite_run)
    GitHubCheckRun.find_by(test_suite_run: @test_suite_run)&.finish!

    return unless @test_suite_run.test_case_runs.failed.any?

    rerun_test_suite_run = TestSuiteRun.create!(
      repository: @test_suite_run.repository,
      branch_name: @test_suite_run.branch_name,
      commit_hash: @test_suite_run.commit_hash,
      commit_message: @test_suite_run.commit_message + " #{SecureRandom.hex}",
      author_name: @test_suite_run.author_name
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
