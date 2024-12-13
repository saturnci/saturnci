require "droplet_kit"

class RunnerSnapshot
  def self.generate!
    client = DropletKitClientFactory.client

    puts "Creating droplet..."
    droplet = create_droplet(client)

    puts "Waiting for droplet to be ready..."
    wait_until_droplet_is_ready(client, droplet.id)

    puts "Droplet is ready, creating snapshot..."
    action = create_snapshot(client, droplet.id)

    puts "Snapshot created with ID: #{action.id}"
    droplet
  end

  private

  def self.create_droplet(client)
    rsa_key = Cloud::RSAKey.new("runner-snapshot-#{Time.now.to_i}")

    droplet_kit_ssh_key = DropletKit::SSHKey.new(
      name: rsa_key.filename,
      public_key: File.read("#{rsa_key.file_path}.pub")
    )

    ssh_key = client.ssh_keys.create(droplet_kit_ssh_key)

    unless ssh_key.id.present?
      raise "SSH key creation not successful"
    end
    
    droplet = DropletKit::Droplet.new(
      name: "runner-snapshot-#{Time.now.to_i}",
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data: user_data,
      ssh_keys: [ssh_key.id]
    )
    
    client.droplets.create(droplet)
  end

  def self.user_data
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

  def self.wait_until_droplet_is_ready(client, droplet_id)
    droplet_info = nil
    loop do
      droplet_info = client.droplets.find(id: droplet_id)
      break if droplet_info.status == 'active'
      sleep(10) # Adjust waiting time as needed
    end
    droplet_info
  end

  def self.create_snapshot(client, droplet_id)
    # Ensure the droplet is powered off before taking a snapshot
    client.droplet_actions.power_off(droplet_id: droplet_id)
    # Waiting for the droplet to power off
    sleep(60) # Adjust timing based on your observations
    client.droplet_actions.snapshot(droplet_id: droplet_id, name: "docker-ruby-snapshot-#{Time.now.to_i}")
  end
end
