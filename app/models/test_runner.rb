class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey"
  has_one :run_test_runner

  scope :unassigned, -> {
    left_joins(:run_test_runner).where(run_test_runners: { run_id: nil })
  }

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
