module Nova
  class DeleteTaskWorkerJob < ApplicationJob
    queue_as :default

    def perform(task_id)
      task = Task.find(task_id)
      Nova.delete_k8s_job(task.worker.name)
    end
  end
end
