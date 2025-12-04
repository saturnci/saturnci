require "base64"

module API
  module V1
    module WorkerAgents
      module Tasks
        class TestOutputsController < WorkerAgentsAPIController
          TAB_NAME = "test_output"

          def create
            task = Task.find(params[:task_id])
            new_content = Base64.decode64(request.body.read).force_encoding('UTF-8')

            Task.connection.execute(
              Task.sanitize_sql([
                "UPDATE tasks SET test_output = COALESCE(test_output, '') || ? WHERE id = ?",
                new_content,
                task.id
              ])
            )

            Streaming::RunOutputStream.new(run: task.reload, tab_name: TAB_NAME).broadcast
            head :ok
          end
        end
      end
    end
  end
end
