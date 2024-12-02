class RunnerRequestSSHKey
  def self.create(client, run)
    client = DropletKitClientFactory.client

    rsa_key = JobMachineRSAKey.new("run-#{run.id}")

    droplet_kit_ssh_key = DropletKit::SSHKey.new(
      name: rsa_key.filename,
      public_key: File.read("#{rsa_key.file_path}.pub")
    )

    client.ssh_keys.create(droplet_kit_ssh_key).tap do |ssh_key|
      unless ssh_key.id.present?
        raise "SSH key creation not successful"
      end
    end
  end
end
