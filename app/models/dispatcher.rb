class Dispatcher
  MAX_NUMBER_OF_VERY_OLD_TEST_RUNNERS_TO_DELETE_AT_ONE_TIME = 10

  def self.check(c = TestRunOrchestrationCheck.new)
    log "-" * 80

    delete_workers(c.old_unassigned_test_runners)
    delete_workers(c.very_old_test_runners.limit(MAX_NUMBER_OF_VERY_OLD_TEST_RUNNERS_TO_DELETE_AT_ONE_TIME))
    remove_orphaned_test_runner_assignments(c.orphaned_test_runner_assignments)

    worker_pool = WorkerPool.instance
    worker_pool.scale(WorkerPool.target_size)

    log "Test runner fleet target size: #{WorkerPool.target_size}"
    log "Available test runners: #{c.available_test_runners.count}"
    log "Unassigned test runners: #{c.unassigned_test_runners.count}"
    log "Unassigned runs: #{c.unassigned_runs.count}"

    c.unassigned_runs.each do |run|
      break if c.available_test_runners.empty?
      test_runner = c.shift_available_test_runner
      log "Assigning #{test_runner.name} to #{run.id}"
      test_runner.assign(run)
    end
  end

  def self.delete_workers(workers)
    log "Deleting #{workers.count} old test runners"
    workers.destroy_all
  end

  def self.remove_orphaned_test_runner_assignments(orphaned_test_runner_assignments)
    log "Deleting #{orphaned_test_runner_assignments.count} orphaned test runners"

    ActiveRecord::Base.transaction do
      orphaned_test_runner_assignments.each do |test_runner_assignment|
        test_runner_assignment.worker.worker_events.create!(type: :error)
        log "Deleting orphaned test runner assignment: #{test_runner_assignment.id}"
        log "Test runner: #{test_runner_assignment.worker.name}"
        test_runner_assignment.destroy
      end
    end
  end

  def self.log(message)
    if Rails.env.production?
      Rails.logger.info message
    else
      puts message
    end
  end
end
