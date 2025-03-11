class TestRunner < ApplicationRecord
  def self.provision(client:, ssh_key:, name:, user_data:)
    specification = DropletKit::Droplet.new(
      name:,
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data:,
      tags: ["saturnci"],
      ssh_keys: [ssh_key.id]
    )

    droplet = client.droplets.create(specification)

    create!(
      name: "test-runner-#{SecureRandom.uuid}",
      cloud_id: droplet.id
    )
  end
end
