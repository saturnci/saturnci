class TestRunnerDropletSpecification
  attr_reader :rsa_key

  def initialize(test_runner_id:, name:)
    @test_runner_id = test_runner_id
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
    admin_user = User.find_by(super_admin: true)

    <<~SCRIPT
      #!/bin/bash

      export TEST_RUNNER_ID=#{@test_runner_id}
      export SATURNCI_API_HOST=#{ENV["SATURNCI_HOST"]}
      export SATURNCI_USER_ID=#{admin_user.id}
      export SATURNCI_USER_API_TOKEN=#{admin_user.api_token}

      export DOCKER_REGISTRY_CACHE_USERNAME=#{ENV["DOCKER_REGISTRY_CACHE_USERNAME"]}
      export DOCKER_REGISTRY_CACHE_PASSWORD=#{ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]}

      cd ~
      git clone https://github.com/saturnci/test_runner_agent.git
      cd test_runner_agent

      bin/test_runner_agent send_ready_signal
    SCRIPT
  end
end
