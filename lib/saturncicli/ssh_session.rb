class SSHSession
  def initialize(ip_address, rsa_file_path)
    @ip_address = ip_address
    @rsa_file_path = rsa_file_path
  end

  def connect
    system(command)
  end

  def command
    "ssh -i #{@rsa_file_path} root@#{@ip_address}"
  end
end
