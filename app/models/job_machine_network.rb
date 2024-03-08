class JobMachineNetwork
  def initialize(job_machine_id)
    @job_machine_id = job_machine_id
  end

  def ip_address
    public_network(droplet)&.ip_address
  end

  private

  def public_network(droplet)
    droplet.networks.v4.find { |network| network.type == 'public' }
  end

  def droplet
    client.droplets.find(id: @job_machine_id)
  end

  def client
    @client ||= DropletKitClientFactory.client
  end
end
