class BuildsController < ApplicationController
  LIMIT = 20

  def index
    project = Project.find(params[:project_id])
    authorize project, :show?

    builds = project.builds

    test_suite_run_list = TestSuiteRunList.new(
      project,
      branch_name: nil,
      statuses: nil
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "additional_test_suite_runs",
          partial: "test_suite_runs/list_items",
          locals: {
            builds: test_suite_run_list.builds.offset(params[:offset]).limit(LIMIT),
            active_build: nil
          }
        )
      end
    end
  end

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
        partial: "test_suite_runs/overview",
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

    @test_suite_run_component = TestSuiteRunComponent.new(
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
