require "base64"

module API
  module V1
    module WorkerAgents
      class SystemLogsController < WorkerAgentsAPIController
      TAB_NAME = "system_logs"

        def create
          begin
            new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

            if new_content.blank?
              head :ok
              return
            end

            task = Task.find(params[:run_id])
            worker_system_log = WorkerSystemLog.find_or_create_by(task: task)
            worker_system_log.update!(content: worker_system_log.content + new_content)

            Streaming::RunOutputStream.new(run: task, tab_name: TAB_NAME).broadcast
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
