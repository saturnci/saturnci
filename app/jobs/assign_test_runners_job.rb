class AssignTestRunnersJob < ApplicationJob
  queue_as :default

  def perform(run_ids)
    runs = Run.find(run_ids)

    while runs.any?
      available_test_runners = nil

      loop do
        available_test_runners = TestRunner.available.to_a

        if available_test_runners.any?
          break
        else
          sleep(rand(1..5)) # avoid hammering the database
          sleep(Rails.configuration.test_runner_availability_check_interval_in_seconds)
        end
      end

      run = runs.shift
      test_runner = available_test_runners.shift
      test_runner.assign(run)
    end
  end
end
