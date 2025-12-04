module API
  module V1
    module WorkerAgents
      class WorkerAssignmentsController < WorkerAgentsAPIController
        def index
          worker = Worker.find(params[:worker_id])

          if worker.worker_assignment.present? && worker.run.test_suite_run.present?
            @worker_assignments = [worker.worker_assignment]
            render :index
          else
            render json: []
          end
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
        end
      end
    end
  end
end
