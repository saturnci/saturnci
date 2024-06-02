# app/controllers/api/v1/system_logs_controller.rb
module API
  module V1
    class SystemLogsController < APIController
      def create
        job = Job.find(params[:job_id])
        request.body.rewind
        log_chunk = request.body.read
        job.update!(system_logs: job.system_logs.to_s + log_chunk)

        respond_to do |format|
          format.turbo_stream do
            @current_tab_name = 'system_logs'
            @job = job
            render 'api/v1/system_logs/create'
          end
          format.json { head :ok }
        end
      end
    end
  end
end
