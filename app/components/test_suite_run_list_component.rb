class TestSuiteRunListComponent < ViewComponent::Base
  attr_reader :test_suite_run, :test_suite_run_filter_component

  def initialize(test_suite_run:, test_suite_run_filter_component:)
    @test_suite_run = test_suite_run
    @test_suite_run_filter_component = test_suite_run_filter_component
  end

  def test_suite_runs
    TestSuiteRunListQuery.new(
      project: @test_suite_run.project,
      branch_name: @test_suite_run_filter_component.branch_name,
      statuses: @test_suite_run_filter_component.checked_statuses
    ).test_suite_runs
  end

  def initial_chunk_of_test_suite_runs
    test_suite_runs.limit(TestSuiteRunListQuery::CHUNK_SIZE)
  end
end
