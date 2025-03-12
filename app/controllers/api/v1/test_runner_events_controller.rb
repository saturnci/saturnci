module API
  module V1
    class TestRunnerEventsController < APIController
      def create
        test_runner = TestRunner.find(params[:test_runner_id])
        authorize test_runner, :update?

        test_runner.test_runner_events.create!(type: params[:type])
        head :created

      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
