module API
  module V1
    module WorkerAgents
      module Tasks
        class JSONOutputsController < WorkerAgentsAPIController
          def create
            begin
              task = Task.find(params[:task_id])
              request.body.rewind
              task.update!(json_output: request.body.read)

              rspec_test_run_summary = RSpecTestRunSummary.new(
                task,
                JSON.parse(task.json_output)
              )

              rspec_test_run_summary.generate_test_case_runs!

            rescue StandardError => e
              render(json: { error: e.message }, status: :bad_request)
              return
            end

            render(
              json: { test_case_run_count: task.test_case_runs.count },
              status: :ok
            )
          end
        end
      end
    end
  end
end
