module WorkerSnapshots
  class DropletRequest
    def initialize(client:, name:)
      @client = client
      @name = "droplet-for-#{name}"
    end

    def execute
      rsa_key = Cloud::RSAKey.generate

      droplet_kit_ssh_key = DropletKit::SSHKey.new(
        name: @name,
        public_key: rsa_key.public_key_value,
      )

      ssh_key = @client.ssh_keys.create(droplet_kit_ssh_key)

      unless ssh_key.id.present?
        raise "SSH key creation not successful"
      end
      
      droplet = DropletKit::Droplet.new(
        name: @name,
        region: DropletConfig::REGION,
        image: "ubuntu-24-10-x64",
        size: "s-2vcpu-8gb-amd",
        user_data: user_data,
        ssh_keys: [ssh_key.id]
      )
      
      @client.droplets.create(droplet)
    end

    def user_data
      <<~USER_DATA
      #!/bin/bash

      apt-get update
      apt-get install -y apt-transport-https ca-certificates curl software-properties-common
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      apt-get update
      apt-get install -y docker-ce

      apt-get install -y curl gpg ruby
      apt-get clean
      rm -rf /var/lib/apt/lists/*
      USER_DATA
    end
  end
end
