require "droplet_kit"

class JobMachineRequest
  def initialize(job:, github_installation_id:)
    @job = job
    @github_installation_id = github_installation_id
  end

  def create!
    client = DropletKitClientFactory.client
    rsa_key = JobMachineRSAKey.new("job-#{@job.id}")

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
      tags: ['saturnci'],
      ssh_keys: [ssh_key.id]
    )

    droplet_request = client.droplets.create(droplet)

    @job.update!(
      snapshot_image_id: DropletConfig::SNAPSHOT_IMAGE_ID,
      job_machine_id: droplet_request.id,
      job_machine_rsa_key_path: rsa_key.file_path
    )
  end

  private

  def droplet_name
    "#{@job.build.project.name.gsub("/", "-")}-job-#{@job.id}"
  end

  def user_data
    JobMachineScript.new(@job, @github_installation_id).content
  end
end
