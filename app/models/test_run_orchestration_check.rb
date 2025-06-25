class TestRunOrchestrationCheck
  TEST_RUNNER_OLDNESS_THRESHOLD = 1.hour

  def old_test_runners
    TestRunner.unassigned.where("test_runners.created_at < ?", TEST_RUNNER_OLDNESS_THRESHOLD.ago)
  end
end
