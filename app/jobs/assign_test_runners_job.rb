class AssignTestRunnersJob < ApplicationJob
  queue_as :default

  def perform(run_ids)
    logger.info "Started with run_ids: #{run_ids.inspect}"

    runs = Run.find(run_ids)
    logger.info "Found #{runs.size} runs to process"

    while runs.any?
      logger.info "Remaining runs: #{runs.size}"

      available_test_runners = nil
      loop do
        ActiveRecord::Base.uncached do
          available_test_runners = TestRunner.available.to_a
        end

        logger.info "Available test runners: #{available_test_runners.size}"

        if available_test_runners.any?
          break
        else
          sleep_interval = Rails.configuration.test_runner_availability_check_interval_in_seconds + rand(1..5)
          logger.info "No test runners available, waiting #{sleep_interval} seconds"
          sleep(Rails.configuration.test_runner_availability_check_interval_in_seconds)
        end
      end

      run = runs.shift
      logger.info "Processing run: #{run.id}"

      test_runner = available_test_runners.shift

      logger.info "Assigning test runner: #{test_runner.id} to run: #{run.id}"
      test_runner.assign(run)
    end

    available_test_runner_count = TestRunner.available.count
    test_runner_pool_size = ENV.fetch("TEST_RUNNER_POOL_SIZE", 10).to_i
    logger.info "Scaling test runner pool from #{available_test_runner_count} to #{test_runner_pool_size}"
    TestRunnerPool.scale(test_runner_pool_size)

    logger.info "Completed"
  end
end
