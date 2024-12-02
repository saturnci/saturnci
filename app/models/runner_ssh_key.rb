class RunnerSSHKey
  attr_reader :rsa_key

  def initialize(run)
    @rsa_key = RunnerRSAKey.new("run-#{run.id}")
  end

  def id
    client = DropletKitClientFactory.client

    droplet_kit_ssh_key = DropletKit::SSHKey.new(
      name: @rsa_key.filename,
      public_key: File.read("#{@rsa_key.file_path}.pub")
    )

    ssh_key = client.ssh_keys.create(droplet_kit_ssh_key)

    unless ssh_key.id.present?
      raise "SSH key creation not successful"
    end

    ssh_key.id
  end
end
