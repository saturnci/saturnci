class AssignTestRunnersJob < ApplicationJob
  queue_as :default

  def perform(run_ids)
    logger.info "[AssignTestRunnersJob] Started with run_ids: #{run_ids.inspect}"
    runs = Run.find(run_ids)
    logger.info "[AssignTestRunnersJob] Found #{runs.size} runs to process"

    while runs.any?
      logger.info "[AssignTestRunnersJob] Remaining runs: #{runs.size}"
      available_test_runners = nil
      loop do
        ActiveRecord::Base.uncached do
          available_test_runners = TestRunner.available.to_a
        end

        logger.info "[AssignTestRunnersJob] Available test runners: #{available_test_runners.size}"
        if available_test_runners.any?
          break
        else
          logger.info "[AssignTestRunnersJob] No test runners available, waiting..."
          sleep(rand(1..5)) # avoid hammering the database
          sleep(Rails.configuration.test_runner_availability_check_interval_in_seconds)
        end
      end
      run = runs.shift
      logger.info "[AssignTestRunnersJob] Processing run: #{run.id}"
      test_runner = available_test_runners.shift
      logger.info "[AssignTestRunnersJob] Assigning test runner: #{test_runner.id} to run: #{run.id}"
      test_runner.assign(run)
    end
    logger.info "[AssignTestRunnersJob] Completed"
  end
end
