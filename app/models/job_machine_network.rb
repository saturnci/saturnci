class JobMachineNetwork
  def initialize(job)
    @job = job
  end

  def ip_address
    network(droplet).ip_address
  end

  private

  def network(droplet)
    droplet.networks.v4.find { |network| network.type == 'public' }
  end

  def droplet
    client.droplets.find(id: @job.job_machine_id)
  end

  def client
    @client ||= DropletKitClientFactory.client
  end
end
