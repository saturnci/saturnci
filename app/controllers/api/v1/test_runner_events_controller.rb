module API
  module V1
    class TestRunnerEventsController < APIController
      def create
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
