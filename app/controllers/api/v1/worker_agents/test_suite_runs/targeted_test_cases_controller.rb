module API
  module V1
    module WorkerAgents
      module TestSuiteRuns
        class TargetedTestCasesController < WorkerAgentsAPIController
          def create
            test_suite_run = TestSuiteRun.find(params[:test_suite_run_id])
            test_set = TestSet.new(params[:test_files])
            render json: test_set.grouped(test_suite_run.tasks.count)
          end
        end
      end
    end
  end
end
