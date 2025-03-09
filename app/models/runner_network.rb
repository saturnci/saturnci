class RunnerNetwork
  def initialize(runner_id)
    @runner_id = runner_id
  end

  def ip_address
    if droplet.nil?
      raise "No droplet found with id '#{@runner_id}'"
    end

    public_network(droplet)&.ip_address
  end

  private

  def public_network(droplet)
    droplet.networks.v4.find { |network| network.type == 'public' }
  end

  def droplet
    client.droplets.find(id: @runner_id)
  end

  def client
    @client ||= DropletKitClientFactory.client
  end
end
