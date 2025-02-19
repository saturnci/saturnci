require "digest"

module SaturnCIRunnerAPI
  class DockerRegistryCache

  def checksum
    Digest::SHA256.hexdigest(File.read("Gemfile.lock") + File.read(".saturnci/Dockerfile"))
  end
end
