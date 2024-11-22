class JobsController < ApplicationController
  def show
    @run = Run.find(params[:id])
    @build = @run.build
    @project = @build.project

    @build_list = BuildList.new(
      @build,
      branch_name: params[:branch_name],
      statuses: params[:statuses]
    )

    @current_tab_name = params[:partial] || DEFAULT_PARTIAL

    @run_output_stream = Streaming::RunOutputStream.new(
      run: @run,
      tab_name: @current_tab_name
    )

    @build_filter_component = BuildFilterComponent.new(
      build: @build,
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      current_tab_name: @current_tab_name
    )

    @project_component = ProjectComponent.new(
      @build.project,
      extra_css_classes: "project-home"
    )
  end
end
