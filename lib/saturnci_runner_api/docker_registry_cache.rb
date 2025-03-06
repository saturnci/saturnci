require "digest"

module SaturnCIRunnerAPI
  class DockerRegistryCache
    URL = "registrycache.saturnci.com:5000"

    def initialize(username:, password:, project_name:, branch_name:)
      @username = username
      @password = password
      @project_name = project_name
      @branch_name = branch_name.gsub(/[^a-zA-Z0-9_.-]/, '-')[0...63]

      # Registry cache IP is sometimes wrong without this.
      system("sudo systemd-resolve --flush-caches")
    end

    def image_url
      "#{URL}/#{@project_name}"
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
