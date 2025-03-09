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
    end
  end
end
