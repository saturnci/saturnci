module Nova
  class CreateWorkerJob < ApplicationJob
    queue_as :default

    def perform(task_id)
      task = Task.find(task_id)
      worker = create_worker(task)
      task.task_events.create!(type: :runner_requested)
      Nova.create_k8s_job(worker, task)
    end

    private

    def create_worker(task)
      worker = Worker.create!(name: worker_name(task), access_token: AccessToken.create!)
      WorkerAssignment.create!(worker:, task:)
      worker
    end

    def worker_name(task)
      silly_name = SillyName.random.gsub(" ", "-")
      repository_name = task.test_suite_run.repository.name.gsub("/", "-")
      "#{repository_name}-#{task.id[0..7]}-#{silly_name}".downcase
    end
  end
end
