module API
  module V1
    module WorkerAgents
      class RunFinishedEventsController < WorkerAgentsAPIController
        def create
          begin
            run = Run.find(params[:run_id])
            ActiveRecord::Base.transaction do
              run.finish!
              run.test_runner.worker_events.create!(type: :test_run_finished)

              if run.build.runs.all?(&:finished?)
                run.build.check_test_case_run_integrity!
                TestSuiteRunLinkComponent.refresh(run.build)
                GitHubCheckRun.find_by(test_suite_run: run.build)&.finish!
              end
            end
          rescue StandardError => e
            render(json: { error: e.message }, status: :bad_request)
            return
          end

          head :ok
        end
      end
    end
  end
end
