class WorkerPool
  include Singleton

  def self.target_size
    if Run.where("runs.created_at > ?", 1.hour.ago).any?
      ENV.fetch("WORKER_POOL_SIZE", "20").to_i
    else
      0
    end
  end

  def scale(count)
    change = count - Worker.unassigned.count

    if change > 0
      ActiveRecord::Base.transaction do
        change.times { Worker.provision }
      end
    else
      ActiveRecord::Base.transaction do
        Worker.unassigned.limit(change.abs).each do |worker|
          worker.destroy
        end
      end
    end
  end

  def prune
    unassigned_workers = Worker.unassigned
    number_of_needed_workers = self.class.target_size - unassigned_workers.count

    if number_of_needed_workers < 0
      unassigned_workers.limit(number_of_needed_workers.abs).each(&:destroy)
    end
  end
end
