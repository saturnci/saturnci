module SaturnCIRunnerAPI
  class DockerComposeStartCommand
    def initialize(docker_compose_configuration:)
      @docker_compose_configuration = docker_compose_configuration
    end

    def to_s
      "#{@docker_compose_configuration.env_vars} docker-compose -f .saturnci/docker-compose.yml up -d"
    end
  end
end
