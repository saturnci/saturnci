class Runner
  def self.destroy_all
    client = DropletKitClientFactory.client

    droplets = client.droplets.all(tag_name: "saturnci")

    droplets.each do |droplet|
      client.droplets.delete(id: droplet.id)
    end
  end

  def self.destroy_orphaned
  end
end
