module API
  module V1
    module TestRunnerAgents
      class RunEventsController < TestRunnerAgentsAPIController
        def create
          run = Run.find(params[:run_id])
          run.run_events.create!(type: params[:type])
          head :ok
        end
      end
    end
  end
end
