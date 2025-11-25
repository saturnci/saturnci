module API
  module V1
    module TestRunnerAgents
      class RunEventsController < APIController
        def create
          run = Run.find(params[:run_id])
          authorize run, :update?

          run.run_events.create!(type: params[:type])
          head :ok
        end
      end
    end
  end
end
