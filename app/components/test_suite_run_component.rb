class TestSuiteRunComponent < ViewComponent::Base
  renders_one :body

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

  def test_suite_run_list
    @test_suite_run_list ||= TestSuiteRunList.new(
      @build.project,
      branch_name: @branch_name,
      statuses: @statuses
    )
  end

  def build_filter_component
    @build_filter_component ||= BuildFilterComponent.new(
      build: @build,
      branch_name: @branch_name,
      checked_statuses: @statuses,
      current_tab_name: @current_tab_name
    )
  end

  def project_component
    @project_component ||= ProjectComponent.new(
      @build.project,
      extra_css_classes: "project-home"
    )
  end
end
