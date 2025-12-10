module Streaming
  class RunOutputStream
    def initialize(task:, tab_name:)
      @task = task
      @tab_name = tab_name
    end

    def name
      "run_#{@task.id}_#{@tab_name}"
    end

    def target
      "run_output_stream_#{@task.id}_#{@tab_name}"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_to(
        name,
        target: target,
        partial: "runs/#{@tab_name}",
        locals: { run: @task, current_tab_name: @tab_name }
      )
    end
  end
end
