class WorkerSnapshot < ApplicationRecord
  def self.generate
    name = "test-runner-snapshot-#{Time.zone.now.to_i}"
    client = DropletKitClientFactory.client

    puts "Creating droplet..."
    droplet = WorkerSnapshots::DropletRequest.new(client:, name:).execute

    puts "Waiting for droplet to be ready..."
    wait_until_droplet_is_ready(client, droplet.id)
    puts "Droplet is ready. ID: #{droplet.id}"

    puts "Creating snapshot..."
    snapshot_action = WorkerSnapshots::SnapshotRequest.new(
      client:,
      droplet_id: droplet.id,
      name:
    ).execute

    puts "Snapshot created. Name: #{name}. Action ID: #{snapshot_action.id}"
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
