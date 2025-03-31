class TestSuiteRunListComponent < ViewComponent::Base
  CHUNK_SIZE = 20
  attr_reader :test_suite_run, :test_suite_run_filter_component

  def initialize(test_suite_run:, branch_name:, statuses:, current_tab_name:, test_suite_run_filter_component:)
    @test_suite_run = test_suite_run
    @branch_name = branch_name
    @statuses = statuses
    @test_suite_run_filter_component = test_suite_run_filter_component
  end

  def test_suite_runs
    test_suite_runs = @test_suite_run.project.test_suite_runs.order("created_at desc")

    if @branch_name.present?
      test_suite_runs = test_suite_runs.where(branch_name: @branch_name)
    end

    if @statuses.present?
      test_suite_runs = test_suite_runs.where("cached_status in (?)", @statuses)
    end

    test_suite_runs
  end

  def initial_chunk_of_test_suite_runs
    test_suite_runs.limit(CHUNK_SIZE)
  end
end
