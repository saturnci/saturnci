module API
  module V1
    module WorkerAgents
      module Tasks
        class TaskEventsController < WorkerAgentsAPIController
          def create
            task = Task.find(params[:task_id])
            task.task_events.create!(type: params[:type])
            head :ok
          end
        end
      end
    end
  end
end
