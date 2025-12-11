module API
  module V1
    class TestSuiteRerunsController < APIController
      def create
        original_test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
        test_suite_run = TestSuiteRerun.create!(original_test_suite_run)
        authorize test_suite_run, :create?

        test_suite_run.start!
        test_suite_run.broadcast

        render json: {
          id: test_suite_run.id,
          runs: test_suite_run.runs.map { |run| { id: run.id } }
        }
      end
    end
  end
end
