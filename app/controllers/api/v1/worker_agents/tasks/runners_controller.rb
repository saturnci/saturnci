module API
  module V1
    module WorkerAgents
      module Tasks
        class RunnersController < WorkerAgentsAPIController
          def destroy
            task = Task.find(params[:task_id])
            task.delete_runner if task.worker.terminate_on_completion

            head :ok
          end
        end
      end
    end
  end
end
