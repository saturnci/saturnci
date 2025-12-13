class TasksController < ApplicationController
  def show
    @task = Task.find(params[:id])
    authorize @task

    @current_tab_name = params[:partial]
    @test_suite_run = @task.test_suite_run
    @repository = @test_suite_run.repository

    @worker_output_stream = Streaming::WorkerOutputStream.new(
      task: @task,
      tab_name: @current_tab_name
    )

    if turbo_frame_request?
      render partial: "tasks/detail", locals: {
        task: @task,
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
