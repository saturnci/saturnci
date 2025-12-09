module Nova
  def self.start_test_suite_run(test_suite_run, tasks)
    ActiveRecord::Base.transaction do
      tasks.each { |task| create_worker(task) }
    end

    tasks.each do |task|
      Nova::CreateK8sPodJob.perform_later(task.worker.id, task.id)
    end

    test_suite_run
  end

  def self.create_worker(task)
    worker = Worker.create!(name: worker_name(task), access_token: AccessToken.create!)
    WorkerAssignment.create!(worker:, task:)
  end

  def self.worker_name(task)
    silly_name = SillyName.random.gsub(" ", "-")
    repository_name = task.test_suite_run.repository.name.gsub("/", "-")
    "#{repository_name}-#{task.id[0..7]}-#{silly_name}".downcase
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

  def self.delete_k8s_job(job_name)
    api_url = ENV.fetch("NOVA_K8S_API_URL")
    token = ENV.fetch("NOVA_K8S_TOKEN")
    ca_cert = ENV.fetch("NOVA_K8S_CA_CERT")

    uri = URI("#{api_url}/apis/batch/v1/namespaces/default/jobs/#{job_name}?propagationPolicy=Background")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.cert_store = OpenSSL::X509::Store.new.tap do |store|
      store.set_default_paths
      store.add_cert(OpenSSL::X509::Certificate.new(ca_cert))
    end

    req = Net::HTTP::Delete.new(uri)
    req["Authorization"] = "Bearer #{token}"

    http.request(req)
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
                imagePullPolicy: "Always",
                resources: {
                  requests: { cpu: "250m", memory: "256Mi" }
                },
                env: [
                  { name: "SATURNCI_API_HOST", value: ENV.fetch("SATURNCI_HOST") },
                  { name: "WORKER_ID", value: worker.id },
                  { name: "WORKER_ACCESS_TOKEN", value: worker.access_token.value },
                  { name: "TASK_ID", value: task.id },
                  { name: "DOCKER_HOST", value: "tcp://localhost:2375" }
                ],
                volumeMounts: [
                  { name: "repository", mountPath: "/repository" },
                  { name: "docker-config", mountPath: "/root/.docker" }
                ]
              },
              {
                name: "dind",
                image: "docker:24-dind",
                securityContext: { privileged: true },
                args: [
                  "--host=tcp://0.0.0.0:2375",
                  "--registry-mirror=https://dockerhub-proxy.saturnci.com:5000"
                ],
                resources: {
                  requests: { cpu: "1250m", memory: "3072Mi" }
                },
                env: [
                  { name: "DOCKER_TLS_CERTDIR", value: "" }
                ],
                volumeMounts: [
                  { name: "dind-storage", mountPath: "/var/lib/docker" },
                  { name: "repository", mountPath: "/repository" },
                  { name: "docker-config", mountPath: "/root/.docker" }
                ]
              }
            ],
            volumes: [
              { name: "dind-storage", emptyDir: {} },
              { name: "repository", emptyDir: {} },
              { name: "docker-config", emptyDir: {} }
            ]
          }
        }
      }
    }
  end
end
