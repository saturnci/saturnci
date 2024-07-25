module API
  module V1
    class SystemLogsController < APIController
      TAB_NAME = "system_logs"

      def create
        job = Job.find(params[:job_id])
        job.update!(TAB_NAME => job.attributes[TAB_NAME].to_s + request.body.read)

        Streaming::JobOutputStream.new(job: job, tab_name: TAB_NAME).broadcast
        head :ok
      end
    end
  end
end
