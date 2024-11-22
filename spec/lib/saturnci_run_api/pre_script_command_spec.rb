require "rails_helper"

RSpec.describe SaturnCIRunnerAPI::PreScriptCommand do
  let!(:docker_compose_configuration) do
    SaturnCIRunnerAPI::DockerComposeConfiguration.new(
      registry_cache_image_url: "registrycache.saturnci.com:5000/saturn_test_app:123456",
      env_vars: { "FOO" => "bar", "BAR" => "baz" }
    )
  end

  let!(:pre_script_command) do
    SaturnCIRunnerAPI::PreScriptCommand.new(
      docker_compose_configuration: docker_compose_configuration
    )
  end

  it "returns a command" do
    expect(pre_script_command.to_s).to eq("script -c \"sudo SATURN_TEST_APP_IMAGE_URL=registrycache.saturnci.com:5000/saturn_test_app:123456 docker-compose -f .saturnci/docker-compose.yml run -e FOO=bar -e BAR=baz saturn_test_app ./.saturnci/pre.sh\"")
  end
end
