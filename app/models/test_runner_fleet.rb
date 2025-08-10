class TestRunnerFleet
  include Singleton

  def self.scale(count)
    ActiveRecord::Base.transaction do
      change = count - TestRunner.unassigned.count
      puts "Change: #{change}"

      if change > 0
        change.times { TestRunner.provision }
      else
        TestRunner.unassigned.limit(change.abs).each do |tr|
          tr.destroy
        end
      end
    end
  end

  def prune(c = TestRunOrchestrationCheck.new)
    test_runner_fleet_size = c.test_runner_fleet_size
    unassigned_test_runners = TestRunner.unassigned
    
    number_of_test_runners = unassigned_test_runners.count
    number_of_needed_test_runners = test_runner_fleet_size - number_of_test_runners
    
    if number_of_needed_test_runners < 0
      unassigned_test_runners.limit(number_of_needed_test_runners.abs).each(&:destroy)
    end
  end
end
