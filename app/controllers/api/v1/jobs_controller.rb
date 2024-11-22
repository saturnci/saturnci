module API
  module V1
    class JobsController < APIController
      def index
        @runs = Run.running
        render 'index', formats: [:json]
      end

      def show
        run = Run.find_by_abbreviated_hash(params[:id])

        render json: run.as_json.merge(
          ip_address: RunnerNetwork.new(run.runner_id).ip_address
        )
      end
    end
  end
end
