class TestSuiteRunsController < ApplicationController
  def create
    test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
    authorize test_suite_run

    test_suite_run.start!
    redirect_to run_path(test_suite_run.runs.first, "test_output")
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
      current_tab_name: params[:partial],
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end

end
