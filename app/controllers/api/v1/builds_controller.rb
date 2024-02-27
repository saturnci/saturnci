module API
  module V1
    class BuildsController < APIController
      def index
        render json: Build.order("created_at desc")
      end
    end
  end
end
