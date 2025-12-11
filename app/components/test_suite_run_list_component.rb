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
    chunk = test_suite_runs.limit(TestSuiteRunListQuery::CHUNK_SIZE).to_a
    debug_active_test_suite_run(chunk)
    chunk
  end

  private

  def debug_active_test_suite_run(chunk)
    active_id = @test_suite_run&.id
    chunk_ids = chunk.map(&:id)
    active_in_chunk = chunk_ids.include?(active_id)

    Rails.logger.info "[DEBUG active_tsr] active_id=#{active_id} active_class=#{@test_suite_run.class} chunk_size=#{chunk_ids.size} active_in_chunk=#{active_in_chunk}"

    unless active_in_chunk
      Rails.logger.warn "[DEBUG active_tsr] ACTIVE NOT IN CHUNK! active_id=#{active_id} chunk_ids=#{chunk_ids.first(5).join(',')}"
    end
  end
end
