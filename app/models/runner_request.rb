require "droplet_kit"

class RunnerRequest
  def initialize(run:, github_installation_id:)
    @run = run
    @github_installation_id = github_installation_id
  end

  def create!
    client = DropletKitClientFactory.client
    rsa_key = JobMachineRSAKey.new("run-#{@run.id}")

    droplet_kit_ssh_key = DropletKit::SSHKey.new(
      name: rsa_key.filename,
      public_key: File.read("#{rsa_key.file_path}.pub")
    )

    ssh_key = client.ssh_keys.create(droplet_kit_ssh_key)

    unless ssh_key.id.present?
      raise "SSH key creation not successful"
    end

    droplet = DropletKit::Droplet.new(
      name: droplet_name,
      region: DropletConfig::REGION,
      image: DropletConfig::SNAPSHOT_IMAGE_ID,
      size: DropletConfig::SIZE,
      user_data: user_data,
      tags: ["saturnci"],
      ssh_keys: [ssh_key.id]
    )

    droplet_request = client.droplets.create(droplet)

    @run.update!(
      snapshot_image_id: DropletConfig::SNAPSHOT_IMAGE_ID,
      runner_id: droplet_request.id,
      runner_rsa_key_path: rsa_key.file_path
    )
  end

  private

  def droplet_name
    "#{@run.build.project.name.gsub("/", "-")}-run-#{@run.id}"
  end

  # /var/lib/cloud/instances/456688083/scripts/part-001
  def user_data
    RunnerScript.new(@run, @github_installation_id).content
  end
end
