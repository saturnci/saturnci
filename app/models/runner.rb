class Runner
  def self.destroy_all
    client = DropletKitClientFactory.client
    droplets = client.droplets.all(tag_name: "saturnci")

    droplets.each do |droplet|
      client.droplets.delete(id: droplet.id)
    end
  end

  def self.destroy_orphaned
    active_runner_ids = Run.running.map(&:runner_id)

    client = DropletKitClientFactory.client
    droplets = client.droplets.all(tag_name: "saturnci")

    droplets.reject do |droplet|
      droplet.id.in?(active_runner_ids)
    end.each do |droplet|
      client.droplets.delete(id: droplet.id)
    end
  end
end
