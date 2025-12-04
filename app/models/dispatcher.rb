class Dispatcher
  MAX_NUMBER_OF_VERY_OLD_WORKERS_TO_DELETE_AT_ONE_TIME = 10

  def self.check(c = TestRunOrchestrationCheck.new)
    log "-" * 80

    delete_workers(c.old_unassigned_workers)
    delete_workers(c.very_old_workers.limit(MAX_NUMBER_OF_VERY_OLD_WORKERS_TO_DELETE_AT_ONE_TIME))
    remove_orphaned_worker_assignments(c.orphaned_worker_assignments)

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

  def self.remove_orphaned_worker_assignments(orphaned_worker_assignments)
    log "Deleting #{orphaned_worker_assignments.count} orphaned workers"

    ActiveRecord::Base.transaction do
      orphaned_worker_assignments.each do |worker_assignment|
        worker_assignment.worker.worker_events.create!(type: :error)
        log "Deleting orphaned worker assignment: #{worker_assignment.id}"
        log "Worker: #{worker_assignment.worker.name}"
        worker_assignment.destroy
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
