module API
  module V1
    class BuildsController < APIController
      DEFAULT_LIMIT = 10

      def index
        builds = Build.order("created_at DESC")
          .limit(DEFAULT_LIMIT)
          .as_json(methods: %w[status duration_formatted])

        render json: builds
      end
    end
  end
end
