require "rails_helper"

RSpec.describe "job machine script" do
  describe "TestSuiteCommand" do
    let!(:rspec_command) do
      JobMachineScript::TestSuiteCommand.new(
        registry_cache_image_url: "registrycache.saturnci.com:5000/saturn_test_app:123456",
        test_files_string: "spec/models/github_token_spec.rb spec/rebuilds_spec.rb spec/sign_up_spec.rb spec/test_spec.rb",
        rspec_seed: "999",
        test_output_filename: "tmp/test_output.txt"
      )
    end

    it "returns a command" do
      docker_compose_command = "docker-compose -f .saturnci/docker-compose.yml run saturn_test_app bundle exec rspec --require ./example_status_persistence.rb --format=documentation --order rand:999 spec/models/github_token_spec.rb spec/rebuilds_spec.rb spec/sign_up_spec.rb spec/test_spec.rb"
      script_env_vars = "SATURN_TEST_APP_IMAGE_URL=registrycache.saturnci.com:5000/saturn_test_app:123456 ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=hJWGiKGSmeeZeUSxkB6uJOeE9mi5MRmD"
      expect(rspec_command.to_s).to eq("script -f tmp/test_output.txt -c \"sudo #{script_env_vars} #{docker_compose_command}\"")
    end
  end
end
