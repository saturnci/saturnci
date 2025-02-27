require "digest"

module SaturnCIRunnerAPI
  class DockerRegistryCache
    URL = "registrycache.saturnci.com:5000"

    def initialize(username:, password:, env_file_path:)
      @username = username
      @password = password
      @env_file_path = env_file_path

      # Registry cache IP is sometimes wrong without this.
      system("sudo systemd-resolve --flush-caches")
    end

    def checksum
      content = File.read("Gemfile.lock") + File.read(".saturnci/Dockerfile")# + File.read(@env_file_path)
      @checksum ||= Digest::SHA256.hexdigest(content)
    end

    def image_url
      "#{URL}/saturn_test_app:#{checksum}"
    end

    def authenticate
      `echo '#{@password}' | docker login #{URL} -u #{@username} --password-stdin`
      $?.success?
    end

    def pull_image
      output = `sudo docker pull #{image_url} 2>&1`

      if output.include?("not found") || output.include?("manifest unknown")
        "Docker registry cache miss. Image not found in registry: #{image_url}"
      else
        "Docker registry cache hit"
      end
    end

    def push_image
      system("sudo docker push #{image_url}")
    end
  end
end
