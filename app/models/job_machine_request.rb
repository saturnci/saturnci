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
    encoded_script = Base64.strict_encode64(script_content)

    <<~SCRIPT
      #!/usr/bin/bash
      export HOST=#{ENV["SATURNCI_HOST"]}
      export JOB_ID=#{@job.id}
      export SATURNCI_API_USERNAME=#{ENV["SATURNCI_API_USERNAME"]}
      export SATURNCI_API_PASSWORD=#{ENV["SATURNCI_API_PASSWORD"]}
      export JOB_ORDER_INDEX=#{@job.order_index}
      export NUMBER_OF_CONCURRENT_JOBS=#{Build::NUMBER_OF_CONCURRENT_JOBS}
      export COMMIT_HASH=#{@job.build.commit_hash}
      export RSPEC_SEED=#{@job.build.seed}
      export GITHUB_INSTALLATION_ID=#{@github_installation_id}
      export GITHUB_REPO_FULL_NAME=#{@job.build.project.github_repo_full_name}

      export USER_ENV_VAR_KEYS="#{@job.build.project.project_secrets.map(&:key).join(",")}"
      #{@job.build.project.project_secrets.map { |secret| "export #{secret.key}=#{secret.value}" }.join("\n")}

      RUBY_SCRIPT_PATH=/tmp/job_machine_script.rb
      echo #{encoded_script} | base64 --decode > $RUBY_SCRIPT_PATH
      ruby $RUBY_SCRIPT_PATH
    SCRIPT
  end

  def script_content
    lib_filename = File.join(Rails.root, "lib", "saturnci_worker_api", "saturnci_worker_api.rb")
    script_filename = File.join(Rails.root, "lib", "job_machine_script.rb")
    File.read(lib_filename) + File.read(script_filename)
  end
end
