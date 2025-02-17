class RunsController < ApplicationController
  def show
    @run = Run.find(params[:id])
    authorize @run

    @current_tab_name = params[:partial]
    @build = @run.build
    @project = @build.project

    @run_output_stream = Streaming::RunOutputStream.new(
      run: @run,
      tab_name: @current_tab_name
    )

    if turbo_frame_request?
      render partial: "runs/detail", locals: {
        run: @run,
        partial: @current_tab_name,
        current_tab_name: @current_tab_name,
        run_output_stream: @run_output_stream
      }

      return
    end

    @build_component = BuildComponent.new(
      build: @build,
      current_tab_name: params[:partial],
      branch_name: params[:branch_name],
      statuses: params[:statuses],
      clear: params[:clear]
    )
  end
end
