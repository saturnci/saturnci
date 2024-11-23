class BuildsController < ApplicationController
  DEFAULT_PARTIAL = "test_output"

  def index
    @project = Project.find(params[:project_id])
    @builds = @project.builds
    render json: { build_count: @builds.count }
  end

  def create
    @project = Project.find(params[:project_id])
    build = Build.new(project: @project)
    build.start!

    redirect_to build
  end

  def show
    @build = Build.find(params[:id])

    if params[:clear]
      params[:branch_name] = nil
      params[:statuses] = nil
    end

    if @build.runs.any?
      failed_runs = @build.runs.select(&:failed?)

      redirect_to job_path(
        failed_runs.first || @build.runs.first,
        DEFAULT_PARTIAL,
        branch_name: params[:branch_name],
        statuses: params[:statuses]
      )
    else
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

  def destroy
    build = Build.find(params[:id])

    begin
      build.delete_runners
    rescue DropletKit::Error => e
      if e.message.include?("404")
        Rails.logger.error "Failed to delete runner: #{e.message}"
      else
        raise
      end
    end

    build.destroy
    redirect_to project_path(build.project)
  end
end
