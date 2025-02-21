module SaturnCIRunnerAPI
  class PreScriptCommand
    def initialize(env_file_path:, docker_registry_cache_image_url:)
      @env_file_path = env_file_path
      @docker_registry_cache_image_url = docker_registry_cache_image_url
    end

    def to_s
      "script -c \"sudo SATURN_TEST_APP_IMAGE_URL=#{@docker_registry_cache_image_url} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose --env-file #{@env_file_path} -f .saturnci/docker-compose.yml run saturn_test_app ./.saturnci/pre.sh"
    end
  end
end
