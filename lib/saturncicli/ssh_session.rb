module SaturnCICLI
  class SSHSession
    def initialize(ip_address:, rsa_key_path:)
      @ip_address = ip_address
      @rsa_key_path = rsa_key_path
    end

    def connect
      system(command)
    end

    def command
      "ssh -o StrictHostKeyChecking=no -i #{@rsa_key_path} root@#{@ip_address}"
    end
  end
end
