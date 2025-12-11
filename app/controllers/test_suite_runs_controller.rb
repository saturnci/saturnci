class TestSuiteRunsController < ApplicationController
  def index
    project = Project.find(params[:project_id])
    authorize project, :show?

    test_suite_run_list_query = TestSuiteRunListQuery.new(
      project: project,
      branch_name: params[:branch_name],
      statuses: params[:statuses]
    )

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "additional_test_suite_runs",
          partial: "test_suite_runs/list_items",
          locals: {
            builds: test_suite_run_list_query.test_suite_runs.offset(params[:offset]).limit(TestSuiteRunListQuery::CHUNK_SIZE),
            test_suite_runs: test_suite_run_list_query.test_suite_runs.offset(params[:offset]).limit(TestSuiteRunListQuery::CHUNK_SIZE),
            active_build: nil,
            active_test_suite_run: nil
          }
        )
      end
    end
  end

  def create
    test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize test_suite_run

    test_suite_run.start!
    redirect_to run_path(test_suite_run.runs.first, "system_logs")
  end

  def show
    @build = Build.find(params[:id])
    @test_suite_run = @build

    authorize @test_suite_run

    if @test_suite_run.test_case_runs.any?
      test_case_run = TestCaseRun.failed_first(@test_suite_run.test_case_runs).first
    end

    if turbo_frame_request?
      render(
        partial: "test_suite_runs/overview",
        locals: {
          build: @test_suite_run,
          test_suite_run: @test_suite_run,
          test_case_run: test_case_run
        }
      )

      return
    end

    if test_case_run.present?
      redirect_to repository_test_case_run_path(
        @test_suite_run.repository,
        test_case_run,
        request.query_parameters
      ) and return
    end

    @test_suite_run_component = TestSuiteRunComponent.new(
      build: @test_suite_run,
      test_suite_run: @test_suite_run,
      current_tab_name: params[:partial],
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end

  def destroy
    test_suite_run = TestSuiteRun.find(params[:id])
    authorize test_suite_run

    begin
      test_suite_run.delete_runners
    rescue DropletKit::Error => e
      if e.message.include?("404")
        Rails.logger.error "Failed to delete runner: #{e.message}"
      else
        raise
      end
    end

    test_suite_run.destroy
    redirect_to repository_path(test_suite_run.repository)
  end

end
