module WorkerSnapshots
  class SnapshotRequest
    def initialize(client:, droplet_id:, name:)
      @client = client
      @droplet_id = droplet_id
      @name = name
    end

    def execute
      @client.droplet_actions.power_off(droplet_id: @droplet_id)
      power_off_initiated_at = Time.zone.now

      # Poll until droplet is powered off
      loop do
        sleep(10) # Check every 5 seconds
        puts "Waited #{(Time.zone.now - power_off_initiated_at).floor} seconds"
        droplet = @client.droplets.find(id: @droplet_id)
        break if droplet.status == 'off'
        puts "Waiting for droplet to power off. Current status: #{droplet.status}"
      end

      @client.droplet_actions.snapshot(
        droplet_id: @droplet_id,
        name: @name
      )
    end
  end
end
