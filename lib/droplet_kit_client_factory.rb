class DropletKitClientFactory
  def self.client
    @client ||= DropletKit::Client.new(access_token: ENV['DIGITALOCEAN_ACCESS_TOKEN'])
  end
end
