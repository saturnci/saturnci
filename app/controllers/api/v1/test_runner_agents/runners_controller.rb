module API
  module V1
    module TestRunnerAgents
      class RunnersController < TestRunnerAgentsAPIController
        def destroy
          run = Run.find(params[:run_id])
          authorize run, :destroy?

          run.delete_runner if run.test_runner.terminate_on_completion

          head :ok
        end
      end
    end
  end
end
