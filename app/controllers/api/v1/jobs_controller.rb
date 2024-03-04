module API
  module V1
    class JobsController < APIController
      def index
        render json: Job.running
      end

      def show
        job = Job.find_by_abbreviated_hash(params[:id])
        render json: job.as_json.merge(ip_address: job.ip_address)
      end
    end
  end
end
