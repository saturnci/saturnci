class TestRunnerDropletSpecification
  def initialize(client:, name:, ssh_key:, user_data:)
    @client = client
    @name = name
    @ssh_key = ssh_key
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
