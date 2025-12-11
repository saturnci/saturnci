class TestSuiteRunListQuery
  CHUNK_SIZE = 20

  def initialize(repository:, branch_name:, statuses:)
    @repository = repository
    @branch_name = branch_name
    @statuses = statuses
  end

  def test_suite_runs
    test_suite_runs = @repository.test_suite_runs.order("created_at desc")

    if @branch_name.present?
      test_suite_runs = test_suite_runs.where(branch_name: @branch_name)
    end

    if @statuses.present?
      test_suite_runs = test_suite_runs.where("cached_status in (?)", @statuses)
    end

    test_suite_runs
  end
end
