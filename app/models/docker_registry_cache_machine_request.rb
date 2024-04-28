require 'droplet_kit'

class DockerRegistryCacheMachineRequest
  # Use a base image that's optimized for Docker installations
  DOCKER_OPTIMIZED_IMAGE_ID = 'docker-20-04'

  def create!
    client = DropletKitClientFactory.client

    # Assuming DropletKitClientFactory.client is already authenticated
    # and ready to use, similar to the example provided.
    droplet = DropletKit::Droplet.new(
      name: 'docker-registry-cache',
      region: 'nyc1',
      image: DOCKER_OPTIMIZED_IMAGE_ID,
      size: 's-1vcpu-2gb',
      user_data: user_data,
      tags: ['docker-registry-cache']
      # This example doesn't include SSH keys for simplicity,
      # but you should include them in a real scenario for secure access.
    )

    droplet_request = client.droplets.create(droplet)

    if droplet_request.id
      puts "Droplet created with ID: #{droplet_request.id}"
    else
      raise "Droplet creation not successful"
    end
  end

  private

  def user_data
    <<~SCRIPT
#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Run a simple Docker Registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2

# Configure UFW to allow traffic on port 5000
ufw allow 5000/tcp
ufw enable
    SCRIPT
  end
end
