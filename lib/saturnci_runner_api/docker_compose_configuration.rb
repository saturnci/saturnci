module SaturnCIRunnerAPI
  class DockerComposeConfiguration
    def initialize(registry_cache_image_url:, env_vars:)
      @registry_cache_image_url = registry_cache_image_url
      @env_vars = env_vars
    end

    def env_vars
      @env_vars.map { |key, value| "-e #{key}=#{value}" }.join(" ")
    end

    def script_env_vars
      "SATURN_TEST_APP_IMAGE_URL=#{@registry_cache_image_url}"
    end
  end
end
