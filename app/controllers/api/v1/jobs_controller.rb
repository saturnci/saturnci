module API
  module V1
    class JobsController < APIController
      def index
        render json: Job.running
      end

      def show
        render json: Job.find(params[:id])
      end
    end
  end
end
