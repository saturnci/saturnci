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
            task = Task.find(params[:task_id])
            new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

            WorkerSystemLog.find_or_create_by!(task: task)
            WorkerSystemLog.connection.execute(
              WorkerSystemLog.sanitize_sql([
                "UPDATE worker_system_logs SET content = COALESCE(content, '') || ? WHERE task_id = ?",
                new_content,
                task.id
              ])
            )

            Streaming::WorkerOutputStream.new(task: task, tab_name: TAB_NAME).broadcast
            head :ok
          end
        end
      end
    end
  end
end
