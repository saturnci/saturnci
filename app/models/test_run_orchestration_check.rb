class TestRunOrchestrationCheck
  WORKER_OLDNESS_THRESHOLD = 1.hour
  VERY_OLD_WORKER_THRESHOLD = 1.day

  attr_reader :available_workers,
    :unassigned_workers,
    :unassigned_runs

  def initialize
    ActiveRecord::Base.uncached do
      @available_workers = Worker.available.shuffle
      @unassigned_workers = Worker.unassigned
    end

    @unassigned_runs = Run.unassigned.where("runs.created_at > ?", 1.day.ago)
  end

  def shift_available_worker
    @available_workers.shift
  end

  def old_unassigned_workers
    Worker.unassigned.where("workers.created_at < ?", WORKER_OLDNESS_THRESHOLD.ago)
  end

  def very_old_workers
    Worker.where("workers.created_at < ?", VERY_OLD_WORKER_THRESHOLD.ago)
  end

  def orphaned_test_runner_assignments
    non_orphaned_workers = Worker.running + Worker.recently_assigned

    TestRunnerAssignment
      .where("worker_assignments.created_at > ?", 1.day.ago)
      .where.not(worker_id: non_orphaned_workers)
  end
end
