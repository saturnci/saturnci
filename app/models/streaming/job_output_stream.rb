module Streaming
  class JobOutputStream
    def initialize(job:, tab_name:)
      @job = job
      @tab_name = tab_name
    end

    def name
      "job_#{@job.id}_#{@tab_name}"
    end

    def target
      "job_output_stream_#{@job.id}_#{@tab_name}"
    end

    def broadcast
      Turbo::StreamsChannel.broadcast_update_to(
        name,
        target: target,
        partial: "jobs/#{@tab_name}",
        locals: { job: @job, current_tab_name: @tab_name }
      )
    end
  end
end
