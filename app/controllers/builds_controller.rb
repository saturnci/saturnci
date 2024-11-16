class BuildsController < ApplicationController
  DEFAULT_PARTIAL = "test_output"

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

    if @build.jobs.any?
      failed_jobs = @build.jobs.select { |job| job.failed? }

      redirect_to job_path(
        failed_jobs.first || @build.jobs.first,
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
      build.delete_job_machines
    rescue DropletKit::Error => e
      if e.message.include?("404")
        Rails.logger.error "Failed to delete job machine: #{e.message}"
      else
        raise
      end
    end

    build.destroy
    redirect_to project_path(build.project)
  end
end
