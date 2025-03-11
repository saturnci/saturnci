module Cloud
  class SSHKey
    attr_reader :rsa_key

    def initialize(rsa_key)
      @run = run
      @rsa_key = rsa_key
    end

    def id
      client = DropletKitClientFactory.client

      droplet_kit_ssh_key = DropletKit::SSHKey.new(
        name: "ssh-key-run-#{@run.id}",
        public_key: @rsa_key.public_key_value
      )

      ssh_key = client.ssh_keys.create(droplet_kit_ssh_key)

      unless ssh_key.id.present?
        raise "SSH key creation not successful"
      end

      ssh_key.id
    end
  end
end
