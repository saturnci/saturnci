module Nova
  def self.start_test_suite_run(test_suite_run)
    ActiveRecord::Base.transaction do
      test_suite_run.repository.concurrency.times do |i|
        task = Task.create!(test_suite_run: test_suite_run, order_index: i + 1)
        task.task_events.create!(type: :runner_requested)
        provision_worker(task)
      end
    end

    test_suite_run
  end

  def self.provision_worker(task)
    access_token = AccessToken.create!
    worker = Worker.create!(name: "nova-#{SecureRandom.hex(4)}", access_token: access_token)
    WorkerAssignment.create!(worker: worker, task: task)
    create_k8s_pod(worker, task)
    worker
  end

  def self.create_k8s_pod(worker, task)
    api_url = ENV.fetch("NOVA_K8S_API_URL")
    token = ENV.fetch("NOVA_K8S_TOKEN")
    ca_cert = ENV.fetch("NOVA_K8S_CA_CERT")

    uri = URI("#{api_url}/api/v1/namespaces/default/pods")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.cert_store = OpenSSL::X509::Store.new.tap do |store|
      store.set_default_paths
      store.add_cert(OpenSSL::X509::Certificate.new(ca_cert))
    end

    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = "Bearer #{token}"
    req["Content-Type"] = "application/json"
    req.body = pod_spec(worker, task).to_json

    response = http.request(req)

    unless response.code.start_with?("2")
      raise "Failed to create K8s pod: #{response.code} #{response.body}"
    end

    response
  end

  def self.pod_spec(worker, task)
    {
      apiVersion: "v1",
      kind: "Pod",
      metadata: {
        name: "nova-#{task.id}",
        labels: {
          app: "nova-worker",
          task_id: task.id
        }
      },
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
              { name: "WORKER_NAME", valueFrom: { fieldRef: { fieldPath: "metadata.name" } } }
            ]
          }
        ]
      }
    }
  end
end
