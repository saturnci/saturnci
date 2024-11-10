module SaturnCIJobAPI
  class TestSuiteCommand
    def initialize(registry_cache_image_url:, test_files_string:, rspec_seed:, test_output_filename:, docker_compose_env_vars:)
      @registry_cache_image_url = registry_cache_image_url
      @test_files_string = test_files_string
      @rspec_seed = rspec_seed
      @test_output_filename = test_output_filename
      @docker_compose_env_vars = docker_compose_env_vars
    end

    def to_s
      "script -f #{@test_output_filename} -c \"sudo #{script_env_vars} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose -f .saturnci/docker-compose.yml run #{docker_compose_env_vars} saturn_test_app #{rspec_command}"
    end

    private

    def script_env_vars
      "SATURN_TEST_APP_IMAGE_URL=#{@registry_cache_image_url}"
    end

    def docker_compose_env_vars
      @docker_compose_env_vars.map { |key, value| "-e #{key}=#{value}" }.join(" ")
    end

    def rspec_command
      "bundle exec rspec --require ./example_status_persistence.rb --format=documentation --order rand:#{@rspec_seed} #{@test_files_string}"
    end
  end
end
