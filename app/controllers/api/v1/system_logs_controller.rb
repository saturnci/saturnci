require "base64"

module API
  module V1
    class SystemLogsController < APIController
      TAB_NAME = "system_logs"

      def create
        begin
          run = Run.find(params[:run_id])
          authorize run, :update?

          new_content = Base64.decode64(request.body.read)
          runner_system_log = RunnerSystemLog.find_or_create_by(run:)
          runner_system_log.update!(content: runner_system_log.content + new_content)

          Streaming::RunOutputStream.new(run: run, tab_name: TAB_NAME).broadcast
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
