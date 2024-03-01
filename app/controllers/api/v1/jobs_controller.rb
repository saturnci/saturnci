module API
  module V1
    class JobsController < APIController
      def index
        render json: Job.running
      end
    end
  end
end
