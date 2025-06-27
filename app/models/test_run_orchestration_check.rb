class TestRunOrchestrationCheck
  TEST_RUNNER_OLDNESS_THRESHOLD = 1.hour
  attr_accessor :available_test_runners, :unassigned_test_runners

  def initialize
    ActiveRecord::Base.uncached do
      @available_test_runners = TestRunner.available.shuffle
      @unassigned_test_runners = TestRunner.unassigned
    end
  end

  def old_test_runners
    TestRunner.unassigned.where("test_runners.created_at < ?", TEST_RUNNER_OLDNESS_THRESHOLD.ago)
  end

  def orphaned_test_runner_assignments
    non_orphaned_test_runners = TestRunner.running + TestRunner.recently_assigned

    TestRunnerAssignment
      .where("test_runner_assignments.created_at > ?", 1.day.ago)
      .where.not(test_runner_id: non_orphaned_test_runners)
  end

  def test_runner_pool_size
    if Run.where("runs.created_at > ?", 1.hour.ago).any?
      ENV.fetch("TEST_RUNNER_POOL_SIZE", 12).to_i
    else
      0
    end
  end
end
