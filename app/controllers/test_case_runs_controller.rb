class TestCaseRunsController < ApplicationController
  def index
    build = Build.find(params[:build_id])
    authorize build, :show?

    test_case_runs = build.test_case_runs

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "test_case_runs",
          partial: "test_case_runs/list",
          locals: { test_case_runs: test_case_runs, build: build }
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

    @build = @test_case_run.run.build

    @build_component = BuildComponent.new(
      build: @build,
      current_tab_name: "overview",
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end
end
