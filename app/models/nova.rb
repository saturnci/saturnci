module Nova
  CLUSTER = "do-nyc2-saturnci-workers-cluster"
  IMAGE = "registry.digitalocean.com/saturnci/worker-agent:latest"

  def self.provision_worker(task)
    access_token = AccessToken.create!
    worker = Worker.create!(name: "nova-#{SecureRandom.hex(4)}", access_token: access_token)
    WorkerAssignment.create!(worker: worker, task: task)

    system(
      "kubectl", "--context", CLUSTER,
      "run", "nova-#{task.id}",
      "--image", IMAGE,
      "--restart=Never",
      "--env", "SATURNCI_API_HOST=https://app.saturnci.com",
      "--env", "WORKER_ID=#{worker.id}",
      "--env", "WORKER_ACCESS_TOKEN=#{worker.access_token.value}",
      "--", "ruby", "-e", worker_script
    )

    worker
  end

  def self.worker_script
    <<~RUBY
      require 'net/http'
      require 'uri'
      require 'json'

      uri = URI("\#{ENV['SATURNCI_API_HOST']}/api/v1/worker_agents/workers/\#{ENV['WORKER_ID']}/worker_events")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Post.new(uri)
      req.basic_auth(ENV['WORKER_ID'], ENV['WORKER_ACCESS_TOKEN'])
      req['Content-Type'] = 'application/json'
      req.body = {type: 'assignment_acknowledged'}.to_json

      res = http.request(req)
      puts "Response: \#{res.code}"
    RUBY
  end
end
