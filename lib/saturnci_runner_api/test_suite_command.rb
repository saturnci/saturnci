module SaturnCIRunnerAPI
  class TestSuiteCommand
    def initialize(docker_registry_cache_image_url:, test_files_string:, rspec_seed:, rspec_documentation_output_filename:)
      @docker_registry_cache_image_url = docker_registry_cache_image_url
      @test_files_string = test_files_string
      @rspec_seed = rspec_seed
      @rspec_documentation_output_filename = rspec_documentation_output_filename
    end

    def to_s
      "script -f #{@rspec_documentation_output_filename} -c \"sudo SATURN_TEST_APP_IMAGE_URL=#{@docker_registry_cache_image_url} #{docker_compose_command.strip}\""
    end

    def docker_compose_command
      "docker-compose -f .saturnci/docker-compose.yml run saturn_test_app #{rspec_command}"
    end

    private

    def rspec_command
      [
        "bundle exec rspec",
        "--require ./example_status_persistence.rb",
        "--format=documentation",
        "--format json --out tmp/json_output.json",
        "--order rand:#{@rspec_seed}",
        @test_files_string
      ].join(' ')
    end
  end
end
