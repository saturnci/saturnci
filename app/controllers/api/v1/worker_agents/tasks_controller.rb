module API
  module V1
    module WorkerAgents
      class TasksController < WorkerAgentsAPIController
        def show
          @task = Task.find(params[:id])
          render :show
        end
      end
    end
  end
end
