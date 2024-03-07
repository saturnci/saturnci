require 'droplet_kit'

class JobMachineRequest
  # This is the ID of the snapshot of the image
  # that we want to use for a job.
  SNAPSHOT_IMAGE_ID = '150149463'

  def initialize(job:, github_installation_id:)
    @job = job
    @github_installation_id = github_installation_id
  end

  def create!
    client = DropletKitClientFactory.client
    rsa_key = JobMachineRSAKey.new(@job)

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
      region: 'nyc1',
      image: SNAPSHOT_IMAGE_ID,
      size: 's-4vcpu-8gb',
      user_data: user_data,
      tags: ['saturnci'],
      ssh_keys: [ssh_key.id]
    )

    droplet_request = client.droplets.create(droplet)
    @job.update!(job_machine_id: droplet_request.id)
  end

  private

  def wait_for_droplet(client, droplet_id)
    loop do
      droplet = client.droplets.find(id: droplet_id)
      return droplet if droplet.status == 'active'

      puts "Waiting for Droplet to become active..."
      sleep 5
    end
  end

  def droplet_name
    "#{@job.build.project.name.gsub("/", "-")}-job-#{@job.id}"
  end

  def user_data
    script_filename = File.join(Rails.root, "lib", "job.sh")

    <<~SCRIPT
      #!/usr/bin/bash
      HOST=#{ENV["SATURNCI_HOST"]}
      JOB_ID=#{@job.id}
      JOB_ORDER_INDEX=#{@job.order_index}
      NUMBER_OF_CONCURRENT_JOBS=#{Build::NUMBER_OF_CONCURRENT_JOBS}
      COMMIT_HASH=#{@job.build.commit_hash}
      RSPEC_SEED=#{@job.build.seed}
      GITHUB_INSTALLATION_ID=#{@github_installation_id}
      GITHUB_REPO_FULL_NAME=#{@job.build.project.github_repo_full_name}
      SATURNCI_API_USERNAME=#{ENV["SATURNCI_API_USERNAME"]}
      SATURNCI_API_PASSWORD=#{ENV["SATURNCI_API_PASSWORD"]}

      #{File.read(script_filename)}
    SCRIPT
  end
end
