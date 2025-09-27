module API
  module V1
    class TestSuiteRunsController < APIController
      DEFAULT_LIMIT = 10

      def index
        test_suite_runs = TestSuiteRun.order("created_at DESC")
          .limit(DEFAULT_LIMIT)
          .as_json(methods: %w[status duration_formatted])

        authorize :test_suite_run, :index?

        render json: test_suite_runs
      end

      def update
        test_suite_run = TestSuiteRun.find(params[:id])
        authorize test_suite_run, :update?

        test_suite_run.update!(test_suite_run_params)
        render json: test_suite_run
      end

      private

      def test_suite_run_params
        params.permit(:dry_run_example_count)
      end
    end
  end
end
