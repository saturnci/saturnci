module API
  module V1
    class TestRunnersController < APIController
      def index
        test_runners = TestRunner.order("created_at desc")
        authorize test_runners
        render json: test_runners
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
