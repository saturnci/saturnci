module API
  module V1
    module WorkerAgents
      module Tasks
        class TaskFinishedEventsController < WorkerAgentsAPIController
          def create
            task = Task.find(params[:task_id])
            TestSuiteRunFinish.new(task).process
            head :ok
          rescue StandardError => e
            render(json: { error: e.message }, status: :bad_request)
          end
        end
      end
    end
  end
end
