module API
  module V1
    class BuildsController < APIController
      def index
        builds = Build.order("created_at DESC").as_json(methods: :status)
        render json: builds
      end
    end
  end
end
