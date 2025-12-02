module API
  module V1
    module WorkerAgents
      class TestSuiteRunsController < WorkerAgentsAPIController
        def update
          test_suite_run = TestSuiteRun.find(params[:id])
          if params.key?(:dry_run_example_count) && params[:dry_run_example_count].to_s !~ /\A\d+\z/
            render json: { error: "dry_run_example_count must be a valid integer" }, status: :unprocessable_entity
            return
          end

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
end
