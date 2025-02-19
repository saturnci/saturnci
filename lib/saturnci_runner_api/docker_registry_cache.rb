require "digest"

module SaturnCIRunnerAPI
  class DockerRegistryCache
    URL = "registrycache.saturnci.com:5000"

    def initialize(username:, password:)
      @username = username
      @password = password

      # Registry cache IP is sometimes wrong without this.
      system("sudo systemd-resolve --flush-caches")
    end

    def checksum
      @checksum ||= Digest::SHA256.hexdigest(File.read("Gemfile.lock") + File.read(".saturnci/Dockerfile"))
    end

    def image_url
      "#{URL}/saturn_test_app:#{checksum}"
    end

    def authenticate
      system("sudo docker login #{URL} -u #{@username} -p #{@password}")
    end

    def pull_image
      system("sudo docker pull #{image_url} || true")
    end

    def push_image
      system("sudo docker tag #{URL}/saturn_test_app #{image_url}")
      system("sudo docker push #{image_url}")
    end
  end
end
