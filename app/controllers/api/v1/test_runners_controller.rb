module API
  module V1
    class TestRunnersController < APIController
      def index
        test_runners = TestRunner.all
        authorize test_runners
        render json: test_runners
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
