module API
  module V1
    module WorkerAgents
      class WorkerEventsController < WorkerAgentsAPIController
        def create
          worker = Worker.find(params[:worker_id])
          worker.worker_events.create!(type: params[:type])
          head :created

        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
        end
      end
    end
  end
end
