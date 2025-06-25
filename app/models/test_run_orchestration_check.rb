class TestRunOrchestrationCheck
  TEST_RUNNER_OLDNESS_THRESHOLD = 1.hour

  def old_test_runners
    TestRunner.unassigned.where("test_runners.created_at < ?", TEST_RUNNER_OLDNESS_THRESHOLD.ago)
  end

  def orphaned_test_runner_assignments
    non_orphaned_test_runners = TestRunner.running + TestRunner.recently_assigned

    TestRunnerAssignment
      .where("test_runner_assignments.created_at > ?", 1.day.ago)
      .where.not(test_runner_id: non_orphaned_test_runners)
  end
end
