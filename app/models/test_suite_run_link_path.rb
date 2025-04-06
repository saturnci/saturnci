class TestSuiteRunLinkPath
  include Rails.application.routes.url_helpers
  DEFAULT_PARTIAL = "test_output"

  def initialize(test_suite_run)
    @test_suite_run = test_suite_run
  end

  def value
    Rails.cache.fetch(cache_key) do
      if @test_suite_run.finished? || @test_suite_run.runs.empty?
        project_test_suite_run_path(@test_suite_run.project, @test_suite_run)
      else
        run_path(first_failed_run || @test_suite_run.runs.sorted.first, DEFAULT_PARTIAL)
      end
    end
  end

  private

  def first_failed_run
    @test_suite_run.runs.select(&:failed?).first
  end

  def cache_key
    [
      "test_suite_run_link_path",
      @test_suite_run.id,
      @test_suite_run.updated_at.to_i
    ].join("/")
  end
end
