module Nova
  class CreateK8sPodJob < ApplicationJob
    queue_as :default

    def perform(worker_id, task_id)
      worker = Worker.find(worker_id)
      task = Task.find(task_id)
      task.task_events.create!(type: :runner_requested)
      Nova.create_k8s_job(worker, task)
    end
  end
end
