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
      sleep(5)
    end
    droplet_info
  end

  def self.create_snapshot(client, droplet_id)
    client.droplet_actions.power_off(droplet_id: droplet_id)
    power_off_initiated_at = Time.zone.now

    # Poll until droplet is powered off
    loop do
      droplet = client.droplets.find(id: droplet_id)
      break if droplet.status == 'off'
      puts "Waiting for droplet to power off. Current status: #{droplet.status}"
      sleep(10) # Check every 5 seconds
      puts "Waited #{(Time.zone.now - power_off_initiated_at).floor} seconds"
    end

    # Create snapshot once droplet is confirmed to be off
    client.droplet_actions.snapshot(droplet_id: droplet_id, name: "docker-ruby-snapshot-#{Time.now.to_i}")
  end
end
