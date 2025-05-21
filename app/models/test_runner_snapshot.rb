class TestRunnerSnapshot < ApplicationRecord
  def self.generate
    client = DropletKitClientFactory.client

    puts "Creating droplet..."
    droplet = TestRunnerSnapshots::DropletRequest.new(client).execute

    puts "Waiting for droplet to be ready..."
    wait_until_droplet_is_ready(client, droplet.id)

    puts "Droplet is ready, creating snapshot..."
    snapshot_action = TestRunnerSnapshots::SnapshotRequest.new(client, droplet.id).execute

    puts "Snapshot created. Action ID: #{snapshot_action.id}"
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
end
