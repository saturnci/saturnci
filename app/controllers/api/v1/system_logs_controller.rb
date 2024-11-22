require "base64"

module API
  module V1
    class SystemLogsController < APIController
      TAB_NAME = "system_logs"

      def create
        run = Run.find(params[:job_id])
        new_content = Base64.decode64(request.body.read)
        existing_content = run.attributes[TAB_NAME].to_s
        run.update!(TAB_NAME => existing_content + new_content)

        Streaming::RunOutputStream.new(run: run, tab_name: TAB_NAME).broadcast
        head :ok
      end
    end
  end
end
