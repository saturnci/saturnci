require "rails_helper"

RSpec.describe "job machine script" do
  describe "RSpecCommand" do
    let!(:rspec_command) do
      JobMachineScript::RSpecCommand.new(
        registry_cache_image_url: "registrycache.saturnci.com:5000/saturn_test_app:123456",
        test_files_string: "spec/models/github_token_spec.rb spec/rebuilds_spec.rb spec/sign_up_spec.rb spec/test_spec.rb",
        rspec_seed: "999",
        test_output_filename: "tmp/test_output.txt"
      )
    end

    it "returns a command" do
      expect(rspec_command.to_s).to eq(<<~COMMAND)
      script -c "sudo SATURN_TEST_APP_IMAGE_URL=registrycache.saturnci.com:5000/saturn_test_app:123456 docker-compose \
        -f .saturnci/docker-compose.yml run saturn_test_app \
        bundle exec rspec --require ./example_status_persistence.rb \
        --format=documentation --order rand:999 spec/models/github_token_spec.rb spec/rebuilds_spec.rb spec/sign_up_spec.rb spec/test_spec.rb" \
        -f "tmp/test_output.txt"
      COMMAND
    end
  end
end
