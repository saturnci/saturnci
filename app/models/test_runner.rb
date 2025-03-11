class TestRunner < ApplicationRecord
  def self.provision(client:, user_data:)
    rsa_key = Cloud::RSAKey.generate
    ssh_key = Cloud::SSHKey.new(rsa_key)

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
      cloud_id: droplet.id,
      rsa_key:,
    )
  end
end
