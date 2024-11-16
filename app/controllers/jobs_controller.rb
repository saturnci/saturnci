class JobsController < ApplicationController
  def show
    @job = Job.find(params[:id])
    @build = @job.build
    @project = @build.project

    @build_list = BuildList.new(
      @build,
      branch_name: params[:branch_name],
      statuses: params[:statuses]
    )

    @current_tab_name = params[:partial] || DEFAULT_PARTIAL

    @job_output_stream = Streaming::JobOutputStream.new(
      job: @job,
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
