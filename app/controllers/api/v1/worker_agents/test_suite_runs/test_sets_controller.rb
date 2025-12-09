module API
  module V1
    module WorkerAgents
      module TestSuiteRuns
        class TestSetsController < WorkerAgentsAPIController
          def update
            test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
            failure_rerun = FailureRerun.find_by(test_suite_run: test_suite_run)

            if failure_rerun
              failed_identifiers = failure_rerun.original_test_suite_run
                .test_case_runs.failed.pluck(:identifier)
              test_set = TestSet.new(failed_identifiers)
            else
              test_set = TestSet.new(params[:test_files])
            end

            render json: test_set.grouped(test_suite_run.tasks.count)
          end
        end
      end
    end
  end
end
