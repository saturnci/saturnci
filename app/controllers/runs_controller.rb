class RunsController < ApplicationController
  def show
    @run = Run.find(params[:id])
    @current_tab_name = params[:partial]
    @build = @run.build
    @project = @build.project

    @run_output_stream = Streaming::RunOutputStream.new(
      run: @run,
      tab_name: @current_tab_name
    )

    if turbo_frame_request?
      render partial: "runs/detail", locals: {
        run: @run,
        partial: @current_tab_name,
        current_tab_name: @current_tab_name,
        run_output_stream: @run_output_stream
      }

      return
    end

    @build_list = BuildList.new(
      @build,
      branch_name: params[:branch_name],
      statuses: params[:statuses]
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
