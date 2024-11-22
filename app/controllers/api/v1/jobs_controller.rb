module API
  module V1
    class JobsController < APIController
      def index
        @jobs = Job.running
        render 'index', formats: [:json]
      end

      def show
        job = Job.find_by_abbreviated_hash(params[:id])

        render json: job.as_json.merge(
          ip_address: RunnerNetwork.new(job.runner_id).ip_address
        )
      end
    end
  end
end
