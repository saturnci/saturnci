class TestSuiteRunLinkComponent < ViewComponent::Base
  DEFAULT_PARTIAL = "test_output"
  attr_reader :build

  def initialize(build, active_build: nil)
    @build = build
    @active_build = active_build
  end

  def path
    Rails.cache.fetch(cache_key) do
      if @build.finished? || @build.runs.empty?
        project_build_path(@build.project, @build)
      else
        run_path(first_failed_run || @build.runs.sorted.first, DEFAULT_PARTIAL)
      end
    end
  end

  def css_class
    @build == @active_build ? "active" : ""
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
