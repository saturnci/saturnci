module JobNetworking
  def ip_address
    client = DropletKitClientFactory.client
    droplet = client.droplets.find(id: job_machine_id)
    ip_address = droplet.networks.v4.find { |network| network.type == 'public' }.ip_address
  end
end
