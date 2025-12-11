class TestCaseRunsController < ApplicationController
  def index
    build = Build.find(params[:build_id])
    authorize build, :show?

    test_case_runs = TestCaseRun.failed_first(build.test_case_runs)[TestCaseRunListComponent::INITIAL_BATCH_SIZE..-1]

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "additional_test_case_runs",
          partial: "test_case_runs/list_items",
          locals: {
            build:,
            test_case_runs:,
            active_test_case_run: nil
          }
        )
      end
    end
  end

  def show
    @test_case_run = TestCaseRun.find(params[:id])
    authorize @test_case_run

    if turbo_frame_request?
      render partial: "test_case_runs/details", locals: { test_case_run: @test_case_run }
      return
    end

    @test_suite_run = @test_case_run.task.test_suite_run

    @test_suite_run_component = TestSuiteRunComponent.new(
      test_suite_run: @test_suite_run,
      current_tab_name: "overview",
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end
end
