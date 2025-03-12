class TestRunner < ApplicationRecord
  belongs_to :rsa_key, class_name: "Cloud::RSAKey", optional: true
  has_one :run_test_runner
  has_many :test_runner_events, dependent: :destroy
  has_many :test_runner_assignments, dependent: :destroy

  scope :unassigned, -> {
    left_joins(:run_test_runner).where(run_test_runners: { run_id: nil })
  }

  scope :available, -> {
    joins(:test_runner_events)
      .where(test_runner_events: { type: :ready_signal_received })
      .where("test_runner_events.created_at = (
        SELECT MAX(created_at) FROM test_runner_events
        WHERE test_runner_events.test_runner_id = test_runners.id
      )")
  }

  def self.provision(client:, user_data: nil)
    rsa_key = Cloud::RSAKey.generate
    name = "tr-#{SecureRandom.uuid[0..7]}-#{SillyName.random.gsub(/ /, "-")}"

    create!(name:).tap do |test_runner|
      droplet_specification = test_runner.droplet_specification(
        ssh_key: Cloud::SSHKey.new(rsa_key, client:),
        user_data: user_data || test_runner.script
      )

      droplet = client.droplets.create(droplet_specification)

      test_runner.update!(rsa_key:, cloud_id: droplet.id)
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
    most_recent_event = test_runner_events.order("created_at desc").first
    return "" if most_recent_event.blank?

    {
      "provision_request_sent" => "Provisioning",
      "ready_signal_received" => "Ready",
      "assignment_acknowledged" => "Assigned",
    }[most_recent_event.type]
  end

  def as_json(options = {})
    super(options).merge(status:)
  end

  def droplet_specification(ssh_key:, user_data:)
    DropletKit::Droplet.new(
      name:,
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data:,
      tags: ["saturnci"],
      ssh_keys: [ssh_key.id]
    )
  end

  def script
    admin_user = User.find_by(super_admin: true)

    <<~SCRIPT
      #!/bin/bash

      export TEST_RUNNER_ID=#{id}
      export SATURNCI_API_HOST=#{ENV["SATURNCI_HOST"]}
      export SATURNCI_API_USER_ID=#{admin_user.id}
      export SATURNCI_API_TOKEN=#{admin_user.api_token}

      export DOCKER_REGISTRY_CACHE_USERNAME=#{ENV["DOCKER_REGISTRY_CACHE_USERNAME"]}
      export DOCKER_REGISTRY_CACHE_PASSWORD=#{ENV["DOCKER_REGISTRY_CACHE_PASSWORD"]}

      cd ~
      git clone https://github.com/saturnci/test_runner_agent.git
      cd test_runner_agent

      bin/test_runner_agent send_ready_signal
    SCRIPT
  end
end
