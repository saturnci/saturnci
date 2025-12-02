module API
  module V1
    module WorkerAgents
      class RunEventsController < WorkerAgentsAPIController
        def create
          run = Run.find(params[:run_id])
          run.run_events.create!(type: params[:type])
          head :ok
        end
      end
    end
  end
end
