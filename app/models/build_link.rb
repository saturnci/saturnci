class BuildLink
  include Rails.application.routes.url_helpers
  DEFAULT_PARTIAL = "test_output"

  def initialize(build, request_query_parameters = {})
    @build = build
    @request_query_parameters = request_query_parameters
  end

  def path
    Rails.cache.fetch(cache_key) do
      if @build.finished? || @build.runs.empty?
        project_build_path(@build.project, @build, @request_query_parameters)
      else
        run_path(
          first_failed_run || @build.runs.sorted.first,
          DEFAULT_PARTIAL,
          @request_query_parameters
        )
      end
    end
  end

  private

  def first_failed_run
    @build.runs.select(&:failed?).first
  end

  def cache_key
    [
      "build_link_path",
      @build.id,
      @build.updated_at.to_i,
      @request_query_parameters.to_s
    ].join("/")
  end
end
