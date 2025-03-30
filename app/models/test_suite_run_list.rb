class TestSuiteRunList
  CHUNK_SIZE = 20

  def initialize(project, branch_name:, statuses:)
    @project = project
    @branch_name = branch_name
    @statuses = statuses
  end

  def test_suite_runs
    test_suite_runs = @project.test_suite_runs.order("created_at desc")

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
