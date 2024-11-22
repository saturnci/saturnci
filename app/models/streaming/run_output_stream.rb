module Streaming
  class RunOutputStream
    def initialize(run:, tab_name:)
      @run = run
      @tab_name = tab_name
    end

    def name
      "run_#{@run.id}_#{@tab_name}"
    end

    def target
      "run_output_stream_#{@run.id}_#{@tab_name}"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_to(
        name,
        target: target,
        partial: "runs/#{@tab_name}",
        locals: { run: @run, current_tab_name: @tab_name }
      )
    end
  end
end
