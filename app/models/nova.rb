module Nova
  def self.start_test_suite_run(test_suite_run, tasks)
    tasks.each do |task|
      worker = create_worker(task)
      task.task_events.create!(type: :worker_requested)
      create_k8s_job(worker, task)
    end

    test_suite_run
  end

  def self.create_worker(task)
    Worker.create!(name: worker_name(task), access_token: AccessToken.create!, task:)
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
    req.body = Nova::JobSpec.build(worker, task).to_json

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

end
