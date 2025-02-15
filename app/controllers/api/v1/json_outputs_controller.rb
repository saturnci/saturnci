module API
  module V1
    class JSONOutputsController < APIController
      def create
        run = Run.find(params[:run_id])
        authorize run, :update?

        request.body.rewind
        run.update!(json_output: request.body.read)

        rspec_test_run_summary = RSpecTestRunSummary.new(
          run,
          JSON.parse(run.json_output)
        )

        rspec_test_run_summary.generate_test_case_runs!

        render(
          json: { test_case_run_count: run.test_case_runs.count },
          status: :ok
        )
      end
    end
  end
end
