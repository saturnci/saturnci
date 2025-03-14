class TestRunnerDropletSpecification
  attr_reader :rsa_key

  def initialize(client:, name:, rsa_key:, user_data:)
    @client = client
    @name = name
    @rsa_key = rsa_key
    @ssh_key = Cloud::SSHKey.new(@rsa_key, client:)
    @user_data = user_data
  end

  def execute
    @client.droplets.create(droplet_specification)
  end

  private

  def droplet_specification
    DropletKit::Droplet.new(
      name: @name,
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data: @user_data,
      tags: ["saturnci"],
      ssh_keys: [@ssh_key.id]
    )
  end
end
