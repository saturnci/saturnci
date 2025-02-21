module SaturnCIRunnerAPI
  class PreScriptCommand
    def initialize(docker_compose_configuration:)
      @docker_compose_configuration = docker_compose_configuration
    end

    def to_s
      "script -c \"sudo docker-compose exec saturn_test_app ./.saturnci/pre.sh\""
    end
  end
end
