class TestRunnerSupervisor
  TEST_RUNNER_POOL_BUFFER = 2

  def self.check
    log "-" * 80

    delete_old_test_runners
    delete_errored_test_runners
    remove_orphaned_test_runner_assignments

    available_test_runners = nil
    unassigned_test_runners = nil

    # bug: this will re-run tests that have already been run
    # if those tests' test runner assignments have been deleted
    unassigned_runs = Run.unassigned.where("runs.created_at > ?", 1.day.ago)

    log "Unassigned runs: #{unassigned_runs.count}"

    ActiveRecord::Base.uncached do
      available_test_runners = TestRunner.available.to_a.shuffle
      unassigned_test_runners = TestRunner.unassigned
    end
    log "Available test runners: #{available_test_runners.count}"
    log "Unassigned test runners: #{unassigned_test_runners.count}"

    if unassigned_test_runners.count < unassigned_runs.count
      number_of_needed_test_runners = unassigned_runs.count - unassigned_test_runners.count
      log "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    end

    unassigned_runs.each do |run|
      break if available_test_runners.empty?
      test_runner = available_test_runners.shift
      log "Assigning #{test_runner.name} to #{run.id}"
      test_runner.assign(run)
    end

    fix_test_runner_pool
  end

  def self.test_runner_pool_size
    ENV.fetch("TEST_RUNNER_POOL_SIZE", 10).to_i
  end

  def self.delete_old_test_runners
    log "-" * 20
    old_test_runners = TestRunner.where("created_at < ?", 1.hour.ago)
    log "Deleting #{old_test_runners.count} old test runners"
    old_test_runners.destroy_all
  end

  def self.delete_errored_test_runners
    log "-" * 20
    errored_test_runners = TestRunner.error
    log "Deleting #{errored_test_runners.count} errored test runners"
    errored_test_runners.destroy_all
  end

  def self.fix_test_runner_pool
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

  def self.remove_orphaned_test_runner_assignments
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

  def self.orphaned_test_runner_assignments
    non_orphaned_test_runners = TestRunner.running + TestRunner.recently_assigned

    TestRunnerAssignment
      .where("test_runner_assignments.created_at > ?", 1.day.ago)
      .where.not(test_runner_id: non_orphaned_test_runners)
  end

  def self.log(message)
    if Rails.env.production?
      Rails.logger.info message
    else
      puts message
    end
  end
end
