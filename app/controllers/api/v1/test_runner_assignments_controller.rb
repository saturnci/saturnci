module API
  module V1
    class TestRunnerAssignmentsController < APIController
      def index
        test_runner = TestRunner.find(params[:test_runner_id])
        authorize test_runner, :show?

        binding.pry
        if test_runner.test_runner_assignment.present? && test_runner.run.test_suite_run.present?
          @test_runner_assignments = [test_runner.test_runner_assignment]
          render :index
        else
          render json: []
        end
      rescue StandardError => e
        render(json: { error: e.message }, status: :bad_request)
      end
    end
  end
end
