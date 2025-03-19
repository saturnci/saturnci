class TestRunnerSupervisor
  def self.check
    Rails.logger.info "-" * 80

    remove_orphaned_test_runner_assignments

    available_test_runners = nil
    unassigned_test_runners = nil

    # bug: this will re-run tests that have already been run
    # if those tests' test runner assignments have been deleted
    unassigned_runs = Run.unassigned.where("runs.created_at > ?", 1.day.ago)

    Rails.logger.info "Unassigned runs: #{unassigned_runs.count}"

    ActiveRecord::Base.uncached do
      available_test_runners = TestRunner.available.to_a.shuffle
      unassigned_test_runners = TestRunner.unassigned
    end
    Rails.logger.info "Available test runners: #{available_test_runners.count}"
    Rails.logger.info "Unassigned test runners: #{unassigned_test_runners.count}"

    if unassigned_test_runners.count < unassigned_runs.count
      number_of_needed_test_runners = unassigned_runs.count - unassigned_test_runners.count
      Rails.logger.info "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    end

    unassigned_runs.each do |run|
      break if available_test_runners.empty?
      test_runner = available_test_runners.shift
      Rails.logger.info "Assigning #{test_runner.name} to #{run.id}"
      test_runner.assign(run)
    end

    test_runner_pool_size = ENV.fetch("TEST_RUNNER_POOL_SIZE", 10).to_i
    Rails.logger.info "Test runner pool size: #{test_runner_pool_size}"

    if unassigned_test_runners.count < test_runner_pool_size
      number_of_needed_test_runners = test_runner_pool_size - unassigned_test_runners.count
      Rails.logger.info "Provisioning #{number_of_needed_test_runners} test runners"
      number_of_needed_test_runners.times { TestRunner.provision }
    end
  end

  def self.remove_orphaned_test_runner_assignments
    Rails.logger.info "Deleting #{orphaned_test_runner_assignments.count} orphaned test runners"

    ActiveRecord::Base.transaction do
      orphaned_test_runner_assignments.each do |test_runner_assignment|
        test_runner_assignment.test_runner.test_runner_events.create!(type: :error)
        Rails.logger.info "Deleting orphaned test runner assignment: #{test_runner_assignment.id}"
        Rails.logger.info "Test runner: #{test_runner_assignment.test_runner.name}"
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
end
