module Nova
  def self.start_test_suite_run(test_suite_run)
    ActiveRecord::Base.transaction do
      test_suite_run.repository.concurrency.times do |i|
        create_task_with_worker(test_suite_run:, order_index: i + 1)
      end
    end

    test_suite_run.tasks.each do |task|
      Nova::CreateK8sPodJob.perform_later(task.worker.id, task.id)
    end

    test_suite_run
  end

  def self.create_task_with_worker(test_suite_run:, order_index:)
    task = Task.create!(test_suite_run:, order_index:)
    task.task_events.create!(type: :runner_requested)

    access_token = AccessToken.create!
    silly_name = SillyName.random.gsub(" ", "-")
    worker_name = "#{test_suite_run.repository.name}-#{task.id[0..7]}-#{silly_name}".downcase
    worker = Worker.create!(name: worker_name, access_token:)
    WorkerAssignment.create!(worker:, task:)

    task
  end

  def self.create_k8s_job(worker, task)
    api_url = ENV.fetch("NOVA_K8S_API_URL")
    token = ENV.fetch("NOVA_K8S_TOKEN")
    ca_cert = ENV.fetch("NOVA_K8S_CA_CERT")

    uri = URI("#{api_url}/apis/batch/v1/namespaces/default/jobs")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.cert_store = OpenSSL::X509::Store.new.tap do |store|
      store.set_default_paths
      store.add_cert(OpenSSL::X509::Certificate.new(ca_cert))
    end

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["Content-Type"] = "application/json"
    req.body = job_spec(worker, task).to_json

    response = http.request(req)

    unless response.code.start_with?("2")
      raise "Failed to create K8s job: #{response.code} #{response.body}"
    end

    response
  end

  def self.job_spec(worker, task)
    {
      apiVersion: "batch/v1",
      kind: "Job",
      metadata: {
        name: worker.name,
        labels: {
          app: "nova-worker",
          task_id: task.id
        }
      },
      spec: {
        ttlSecondsAfterFinished: 10,
        activeDeadlineSeconds: 3600,
        backoffLimit: 0,
        template: {
          spec: {
            restartPolicy: "Never",
            containers: [
              {
                name: "worker",
                image: "registry.digitalocean.com/saturnci/nova-worker-agent:latest",
                env: [
                  { name: "SATURNCI_API_HOST", value: "https://app.saturnci.com" },
                  { name: "WORKER_ID", value: worker.id },
                  { name: "WORKER_ACCESS_TOKEN", value: worker.access_token.value },
                  { name: "TASK_ID", value: task.id },
                  { name: "DOCKER_HOST", value: "tcp://localhost:2375" }
                ],
                volumeMounts: [
                  { name: "repository", mountPath: "/repository" }
                ]
              },
              {
                name: "dind",
                image: "docker:24-dind",
                securityContext: { privileged: true },
                env: [
                  { name: "DOCKER_TLS_CERTDIR", value: "" }
                ],
                volumeMounts: [
                  { name: "dind-storage", mountPath: "/var/lib/docker" },
                  { name: "repository", mountPath: "/repository" }
                ]
              }
            ],
            volumes: [
              { name: "dind-storage", emptyDir: {} },
              { name: "repository", emptyDir: {} }
            ]
          }
        }
      }
    }
  end
end
