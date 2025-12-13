class RunsController < ApplicationController
  def show
    @run = Run.find(params[:id])
    authorize @run

    @current_tab_name = params[:partial]
    @test_suite_run = @run.test_suite_run
    @repository = @test_suite_run.repository

    @worker_output_stream = Streaming::WorkerOutputStream.new(
      task: @run,
      tab_name: @current_tab_name
    )

    if turbo_frame_request?
      render partial: "runs/detail", locals: {
        run: @run,
        partial: @current_tab_name,
        current_tab_name: @current_tab_name,
        worker_output_stream: @worker_output_stream
      }

      return
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
end
