require "digest"

module SaturnCIRunnerAPI
  class DockerRegistryCache
    URL = "registrycache.saturnci.com:5000"

    def checksum
      Digest::SHA256.hexdigest(File.read("Gemfile.lock") + File.read(".saturnci/Dockerfile"))
    end

    def image_url
      "#{URL}/saturn_test_app:#{checksum}"
    end
  end
end
