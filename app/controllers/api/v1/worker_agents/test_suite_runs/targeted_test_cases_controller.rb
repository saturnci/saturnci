module API
  module V1
    module WorkerAgents
      module TestSuiteRuns
        class TargetedTestCasesController < WorkerAgentsAPIController
          def create
            test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
            divider = TestFileDivider.new(
              test_files: params[:test_files],
              task_count: test_suite_run.tasks.count
            )
            render json: divider.divide
          end
        end
      end
    end
  end
end
