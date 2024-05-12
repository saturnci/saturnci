module API
  module V1
    class SystemLogsController < APIController
      def create
        job = Job.find(params[:job_id])
        request.body.rewind
        log_chunk = request.body.read
        job.update!(system_logs: job.system_logs.to_s + log_chunk)

        head :ok
      end
    end
  end
end
