# app/controllers/api/v1/system_logs_controller.rb
module API
  module V1
    class SystemLogsController < APIController
      def create
        job = Job.find(params[:job_id])
        request.body.rewind
        log_chunk = request.body.read
        job.update!(system_logs: job.system_logs.to_s + log_chunk)

        Turbo::StreamsChannel.broadcast_append_to(
          "job_#{job.id}_system_logs",
          target: "build-details-content",
          partial: "jobs/system_logs",
          locals: { job: job, current_tab_name: "system_logs" }
        )

        respond_to do |format|
          format.json { head :ok }
        end
      end
    end
  end
end
