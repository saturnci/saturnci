class TestRunnerSnapshot < ApplicationRecord
  def self.generate
    client = DropletKitClientFactory.client

    puts "Creating droplet..."
    droplet = TestRunnerSnapshots::DropletRequest.new(client).execute

    puts "Waiting for droplet to be ready..."
    wait_until_droplet_is_ready(client, droplet.id)

    puts "Droplet is ready, creating snapshot..."
    action = create_snapshot(client, droplet.id)

    puts "Snapshot created with ID: #{action.id}"
    droplet
  end

  private

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
