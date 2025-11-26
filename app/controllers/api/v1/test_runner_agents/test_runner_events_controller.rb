module API
  module V1
    module TestRunnerAgents
      class TestRunnerEventsController < TestRunnerAgentsAPIController
        def create
          test_runner = TestRunner.find(params[:test_runner_id])
          test_runner.test_runner_events.create!(type: params[:type])
          head :created

        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
        end
      end
    end
  end
end
