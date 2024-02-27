module API
  module V1
    class BuildsController < APIController
      def index
        render json: Build.all
      end
    end
  end
end
