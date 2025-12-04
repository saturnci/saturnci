class WorkerDropletSpecification
  attr_reader :rsa_key

  def initialize(worker:, name:)
    @worker = worker
    @client = DropletKitClientFactory.client
    @name = name
    @rsa_key = Cloud::RSAKey.generate
    @ssh_key = Cloud::SSHKey.new(@rsa_key, client: @client)
  end

  def execute
    @client.droplets.create(droplet_specification)
  end

  private

  def droplet_specification
    worker_snapshot = WorkerSnapshot.order("created_at desc").first

    DropletKit::Droplet.new(
      name: @name,
      region: DropletConfig::REGION,
      image: worker_snapshot.cloud_id,
      size: worker_snapshot.size,
      user_data:,
      tags: ["saturnci"],
      ssh_keys: [@ssh_key.id]
    )
  end

  def user_data
    <<~SCRIPT
      #!/bin/bash

      export SATURNCI_API_HOST=#{ENV["SATURNCI_HOST"]}
      export WORKER_ID=#{@worker.id}
      export WORKER_ACCESS_TOKEN=#{@worker.access_token.value}

      export DOCKER_REGISTRY_CACHE_USERNAME=#{ENV["DOCKER_REGISTRY_CACHE_USERNAME"]}
      export DOCKER_REGISTRY_CACHE_PASSWORD=#{ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]}

      cd ~
      git clone https://github.com/saturnci/worker_agent.git worker_agent
      cd worker_agent
      bin/worker_agent send_ready_signal
    SCRIPT
  end
end
