class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey"

  def self.provision(client:, user_data: nil)
    rsa_key = Cloud::RSAKey.generate
    ssh_key = Cloud::SSHKey.new(rsa_key, client:)
    name = "tr-#{SecureRandom.uuid[0..7]}-#{SillyName.random.gsub(/ /, "-")}"

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
    create!(name:, rsa_key:, cloud_id: droplet.id)
  end
end
