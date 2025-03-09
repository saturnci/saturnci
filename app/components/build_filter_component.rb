class BuildFilterComponent < ViewComponent::Base
  STATUSES = [
    "Passed",
    "Failed",
    "Running",
    "Cancelled",
    "Not Started"
  ]

  def initialize(test_suite_run:, branch_name:, checked_statuses:, current_tab_name:)
    @test_suite_run = test_suite_run
    @branch_name = branch_name
    @checked_statuses = checked_statuses
    @current_tab_name = current_tab_name
  end

  def checked?(status)
    @checked_statuses&.include?(status)
  end

  def branch_names
    @test_suite_run.project.test_suite_runs.map(&:branch_name).uniq
  end

  def statuses
    STATUSES
  end
end
