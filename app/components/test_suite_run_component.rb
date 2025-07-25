class TestSuiteRunComponent < ViewComponent::Base
  renders_one :body
  attr_reader :build

  def initialize(build:, current_tab_name: nil, branch_name: nil, statuses: nil, clear: false)
    @build = build
    @current_tab_name = current_tab_name
    @branch_name = branch_name
    @statuses = statuses

    if clear
      @branch_name = nil
      @statuses = nil
    end
  end

  def test_suite_run_filter_component
    @test_suite_run_filter_component ||= TestSuiteRunFilterComponent.new(
      test_suite_run: @build,
      branch_name: @branch_name,
      checked_statuses: @statuses,
      current_tab_name: @current_tab_name
    )
  end

  def repository_component
    @repository_component ||= RepositoryComponent.new(
      @build.repository,
      extra_css_classes: "repository-home"
    )
  end
end
