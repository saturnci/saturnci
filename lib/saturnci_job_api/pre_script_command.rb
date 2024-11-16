module SaturnCIJobAPI
  class PreScriptCommand
    def initialize(docker_compose_configuration:)
      @docker_compose_configuration = docker_compose_configuration
    end

    def to_s
      "script -c \"sudo #{@docker_compose_configuration.script_env_vars} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose -f .saturnci/docker-compose.yml run #{@docker_compose_configuration.env_vars} saturn_test_app ./.saturnci/pre.sh"
    end
  end
end
