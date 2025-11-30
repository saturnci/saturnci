class WorkerDropletSpecification
  attr_reader :rsa_key

  def initialize(test_runner:, name:)
    @test_runner = test_runner
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
    test_runner_snapshot = TestRunnerSnapshot.order("created_at desc").first

    DropletKit::Droplet.new(
      name: @name,
      region: DropletConfig::REGION,
      image: test_runner_snapshot.cloud_id,
      size: test_runner_snapshot.size,
      user_data:,
      tags: ["saturnci"],
      ssh_keys: [@ssh_key.id]
    )
  end

  def user_data
    <<~SCRIPT
      #!/bin/bash

      export TEST_RUNNER_ID=#{@test_runner.id}
      export SATURNCI_API_HOST=#{ENV["SATURNCI_HOST"]}
      export TEST_RUNNER_ACCESS_TOKEN=#{@test_runner.access_token.value}

      export DOCKER_REGISTRY_CACHE_USERNAME=#{ENV["DOCKER_REGISTRY_CACHE_USERNAME"]}
      export DOCKER_REGISTRY_CACHE_PASSWORD=#{ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]}

      cd ~
      if git clone https://github.com/saturnci/worker_agent.git worker_agent 2>/dev/null; then
        cd worker_agent
      elif git clone https://github.com/saturnci/test_runner_agent.git worker_agent; then
        cd worker_agent
      else
        echo "Failed to clone agent repo" && exit 1
      fi

      bin/test_runner_agent send_ready_signal
    SCRIPT
  end
end
