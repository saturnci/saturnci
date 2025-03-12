module API
  module V1
    class TestRunnerAssignmentsController < APIController
      def index
        test_runner = TestRunner.find(params[:test_runner_id])
        authorize test_runner, :show?

        @test_runner_assignments = test_runner.test_runner_assignments
        render :index
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
