class BuildLink
  include Rails.application.routes.url_helpers
  DEFAULT_PARTIAL = "test_output"

  def initialize(build)
    @build = build
  end

  def path
    if @build.runs.any?
      run_path(first_failed_run || @build.runs.first, DEFAULT_PARTIAL)
    else
      project_build_path(@build.project, @build)
    end
  end

  private

  def first_failed_run
    @build.runs.select(&:failed?).first
  end
end
