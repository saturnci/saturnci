module SaturnCIRunnerAPI
  class PreScriptCommand
    def initialize(docker_compose_configuration:, env_file_path:)
      @docker_compose_configuration = docker_compose_configuration
      @env_file_path = env_file_path
    end

    def to_s
      "script -c \"sudo #{@docker_compose_configuration.script_env_vars} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose --env-file #{@env_file_path} -f .saturnci/docker-compose.yml run saturn_test_app ./.saturnci/pre.sh"
    end
  end
end
