class TestRunnerFleet
  include Singleton

  def self.target_size
    if Run.where("runs.created_at > ?", 1.hour.ago).any?
      ENV.fetch("TEST_RUNNER_FLEET_SIZE", 20).to_i
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
        Worker.unassigned.limit(change.abs).each do |tr|
          tr.destroy
        end
      end
    end
  end

  def prune
    unassigned_test_runners = Worker.unassigned
    number_of_needed_test_runners = self.class.target_size - unassigned_test_runners.count
    
    if number_of_needed_test_runners < 0
      unassigned_test_runners.limit(number_of_needed_test_runners.abs).each(&:destroy)
    end
  end
end
