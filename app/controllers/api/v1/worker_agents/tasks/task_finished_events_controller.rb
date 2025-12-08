module API
  module V1
    module WorkerAgents
      module Tasks
        class TaskFinishedEventsController < WorkerAgentsAPIController
          def create
            task = Task.find(params[:task_id])

            ActiveRecord::Base.transaction do
              task.finish!
              task.worker.worker_events.create!(type: :test_run_finished)

              if task.test_suite_run.tasks.all?(&:finished?)
                TestSuiteRunFinish.new(task.test_suite_run).process
              end
            end

            Nova::DeleteK8sJobJob.perform_later(task.worker.name)
            head :ok
          rescue StandardError => e
            render(json: { error: e.message }, status: :bad_request)
          end
        end
      end
    end
  end
end
