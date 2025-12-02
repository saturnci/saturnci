module API
  module V1
    module WorkerAgents
      class RunnersController < WorkerAgentsAPIController
        def destroy
          run = Run.find(params[:run_id])
          run.delete_runner if run.test_runner.terminate_on_completion

          head :ok
        end
      end
    end
  end
end
