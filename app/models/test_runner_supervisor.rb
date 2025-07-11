class TestRunnerSupervisor
  TEST_RUNNER_POOL_BUFFER = 2
  MAX_NUMBER_OF_VERY_OLD_TEST_RUNNERS_TO_DELETE_AT_ONE_TIME = 10

  def self.check(c = TestRunOrchestrationCheck.new)
    log "-" * 80

    delete_test_runners(c.old_unassigned_test_runners)
    delete_test_runners(c.very_old_test_runners.limit(MAX_NUMBER_OF_VERY_OLD_TEST_RUNNERS_TO_DELETE_AT_ONE_TIME))
    remove_orphaned_test_runner_assignments(c.orphaned_test_runner_assignments)
    fix_test_runner_pool(c.test_runner_pool_size)

    log "Unassigned runs: #{c.unassigned_runs.count}"
    log "Available test runners: #{c.available_test_runners.count}"
    log "Unassigned test runners: #{c.unassigned_test_runners.count}"

    c.unassigned_runs.each do |run|
      break if c.available_test_runners.empty?
      test_runner = c.shift_available_test_runner
      log "Assigning #{test_runner.name} to #{run.id}"
      test_runner.assign(run)
    end
  end

  def self.delete_test_runners(test_runners)
    log "-" * 20
    log "Deleting #{test_runners.count} old test runners"
    test_runners.destroy_all
  end

  def self.fix_test_runner_pool(test_runner_pool_size)
    log "-" * 20
    log "Desired test runner pool size: #{test_runner_pool_size}"

    unassigned_test_runners = TestRunner.unassigned

    number_of_test_runners = unassigned_test_runners.count
    log "Number of unassigned test runners: #{number_of_test_runners}"

    number_of_needed_test_runners = test_runner_pool_size - number_of_test_runners
    log "Change needed: #{number_of_needed_test_runners}"

    if number_of_needed_test_runners > 0
      log "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    elsif number_of_needed_test_runners < 0
      log "Deleting #{number_of_needed_test_runners.abs} unassigned test runners"
      unassigned_test_runners[0..(number_of_needed_test_runners.abs - 1)].each(&:destroy)
    end
  end

  def self.remove_orphaned_test_runner_assignments(orphaned_test_runner_assignments)
    log "Deleting #{orphaned_test_runner_assignments.count} orphaned test runners"

    ActiveRecord::Base.transaction do
      orphaned_test_runner_assignments.each do |test_runner_assignment|
        test_runner_assignment.test_runner.test_runner_events.create!(type: :error)
        log "Deleting orphaned test runner assignment: #{test_runner_assignment.id}"
        log "Test runner: #{test_runner_assignment.test_runner.name}"
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
