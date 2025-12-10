require "base64"

module API
  module V1
    module WorkerAgents
      module Tasks
        class SystemLogsController < WorkerAgentsAPIController
          TAB_NAME = "system_logs"

          def index
            task = Task.find(params[:task_id])
            runner_system_log = RunnerSystemLog.find_by(task: task)
            content = runner_system_log&.content || ""
            render json: { content: content }
          end

          def create
            begin
              new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

              if new_content.blank?
                head :ok
                return
              end

              task = Task.find(params[:task_id])
              runner_system_log = RunnerSystemLog.find_or_create_by(task: task)
              runner_system_log.update!(content: runner_system_log.content + new_content)

              Streaming::RunOutputStream.new(task: task, tab_name: TAB_NAME).broadcast
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
end
