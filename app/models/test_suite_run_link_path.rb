class TestSuiteRunLinkPath
  include Rails.application.routes.url_helpers
  DEFAULT_PARTIAL = "test_output"

  def initialize(build)
    @build = build
  end

  def value
    Rails.cache.fetch(cache_key) do
      if @build.finished? || @build.runs.empty?
        project_build_path(@build.project, @build)
      else
        run_path(first_failed_run || @build.runs.sorted.first, DEFAULT_PARTIAL)
      end
    end
  end

  private

  def first_failed_run
    @build.runs.select(&:failed?).first
  end

  def cache_key
    [
      "test_suite_run_link_path",
      @build.id,
      @build.updated_at.to_i
    ].join("/")
  end
end
