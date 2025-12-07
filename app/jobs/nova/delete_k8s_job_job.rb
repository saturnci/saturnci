module Nova
  class DeleteK8sJobJob < ApplicationJob
    queue_as :default

    def perform(job_name)
      Nova.delete_k8s_job(job_name)
    end
  end
end
