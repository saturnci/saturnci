class Dispatcher
  MAX_NUMBER_OF_VERY_OLD_WORKERS_TO_DELETE_AT_ONE_TIME = 10

  def self.check(c = TestRunOrchestrationCheck.new)
    log "-" * 80

    delete_workers(c.old_unassigned_workers)
    delete_workers(c.very_old_workers.limit(MAX_NUMBER_OF_VERY_OLD_WORKERS_TO_DELETE_AT_ONE_TIME))
    remove_orphaned_test_runner_assignments(c.orphaned_test_runner_assignments)

    worker_pool = WorkerPool.instance
    worker_pool.scale(WorkerPool.target_size)

    log "Worker pool target size: #{WorkerPool.target_size}"
    log "Available workers: #{c.available_workers.count}"
    log "Unassigned workers: #{c.unassigned_workers.count}"
    log "Unassigned runs: #{c.unassigned_runs.count}"

    c.unassigned_runs.each do |run|
      break if c.available_workers.empty?
      worker = c.shift_available_worker
      log "Assigning #{worker.name} to #{run.id}"
      worker.assign(run)
    end
  end

  def self.delete_workers(workers)
    log "Deleting #{workers.count} old workers"
    workers.destroy_all
  end

  def self.remove_orphaned_test_runner_assignments(orphaned_test_runner_assignments)
    log "Deleting #{orphaned_test_runner_assignments.count} orphaned workers"

    ActiveRecord::Base.transaction do
      orphaned_test_runner_assignments.each do |test_runner_assignment|
        test_runner_assignment.worker.worker_events.create!(type: :error)
        log "Deleting orphaned test runner assignment: #{test_runner_assignment.id}"
        log "Worker: #{test_runner_assignment.worker.name}"
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
