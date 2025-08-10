class TestRunOrchestrationCheck
  TEST_RUNNER_OLDNESS_THRESHOLD = 1.hour
  VERY_OLD_TEST_RUNNER_THRESHOLD = 1.day

  attr_reader :available_test_runners,
    :unassigned_test_runners,
    :unassigned_runs

  def initialize
    ActiveRecord::Base.uncached do
      @available_test_runners = TestRunner.available.shuffle
      @unassigned_test_runners = TestRunner.unassigned
    end

    @unassigned_runs = Run.unassigned.where("runs.created_at > ?", 1.day.ago)
  end

  def shift_available_test_runner
    @available_test_runners.shift
  end

  def old_unassigned_test_runners
    TestRunner.unassigned.where("test_runners.created_at < ?", TEST_RUNNER_OLDNESS_THRESHOLD.ago)
  end

  def very_old_test_runners
    TestRunner.where("test_runners.created_at < ?", VERY_OLD_TEST_RUNNER_THRESHOLD.ago)
  end

  def orphaned_test_runner_assignments
    non_orphaned_test_runners = TestRunner.running + TestRunner.recently_assigned

    TestRunnerAssignment
      .where("test_runner_assignments.created_at > ?", 1.day.ago)
      .where.not(test_runner_id: non_orphaned_test_runners)
  end

  def test_runner_fleet_size
    if Run.where("runs.created_at > ?", 1.hour.ago).any?
      ENV.fetch("TEST_RUNNER_FLEET_SIZE", 12).to_i
    else
      0
    end
  end
end
