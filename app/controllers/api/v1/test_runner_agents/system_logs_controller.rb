require "base64"

module API
  module V1
    module TestRunnerAgents
      class SystemLogsController < TestRunnerAgentsAPIController
      TAB_NAME = "system_logs"

        def create
          begin
            new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

            if new_content.blank?
              head :ok
              return
            end

            run = Run.find(params[:run_id])
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
end
