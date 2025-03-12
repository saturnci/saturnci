class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey"
  has_one :run_test_runner
  has_many :test_runner_events, dependent: :destroy

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

    create!(name:, rsa_key:, cloud_id: droplet.id).tap do |test_runner|
      test_runner.test_runner_events.create!(type: :provision_request_sent)
    end
  end

  def deprovision(client)
    client.droplets.delete(id: cloud_id)
    destroy!
  rescue DropletKit::Error => e
    Rails.logger.error "Error deleting test runner: #{e.message}"
  end

  def status
    most_recent_event = test_runner_events.order("created_at desc").first.type

    {
      "provision_request_sent" => "provisioning",
      "ready_signal_received" => "ready",
    }[most_recent_event]
  end
end
