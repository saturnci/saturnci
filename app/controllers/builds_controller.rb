class BuildsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    build = Build.new(project: @project)
    authorize build

    build.start!

    redirect_to build
  end

  def show
    @build = Build.find(params[:id])

    authorize @build

    if @build.test_case_runs.any?
      test_case_run = TestCaseRun.failed_first(@build.test_case_runs).first
    end

    if turbo_frame_request?
      render(
        partial: "builds/overview",
        locals: {
          build: @build,
          test_case_run: test_case_run
        }
      )

      return
    end

    if test_case_run.present?
      redirect_to project_test_case_run_path(
        @build.project,
        test_case_run,
        request.query_parameters
      ) and return
    end

    @build_component = BuildComponent.new(
      build: @build,
      current_tab_name: params[:partial],
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end

  def destroy
    build = Build.find(params[:id])
    authorize build

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
