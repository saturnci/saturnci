require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  before do
    AuthenticationHelper.stub_authentication_request
    allow_any_instance_of(SaturnCICLI::SSHSession).to receive(:connect)

    stub_request(:patch, "https://app.saturnci.com/api/v1/test_runners/abc123").
      to_return(status: 200, body: "", headers: {})
  end

  let!(:credential) do
    SaturnCICLI::Credential.new(
      user_id: "valid_user_id",
      api_token: "valid_api_token"
    )
  end


  let!(:client) do
    SaturnCICLI::Client.new(credential)
  end

  let!(:test_runner) do
    instance_double(SaturnCICLI::TestRunner)
  end

  before do
    allow(test_runner).to receive(:refresh).and_return(test_runner)
    allow(test_runner).to receive(:id).and_return("abc123")
  end

  context "remote machine has an IP address" do
    let!(:body) do
      { "ip_address" => "111.11.11.1" }
    end

    before do
      APIHelper.stub_body("api/v1/test_runners/abc123", body)
      allow(test_runner).to receive(:ip_address).and_return("111.11.11.1")
      allow(test_runner).to receive(:rsa_key_path).and_return("/tmp/saturnci/test-runner-abc123")
    end

    it "outputs the test runner id" do
      expect do
        command = "--test-runner abc123 ssh"
        client.ssh(test_runner)
      end.to output("ssh -o StrictHostKeyChecking=no -i /tmp/saturnci/test-runner-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  context "remote machine does not yet have an IP address" do
    before do
      APIHelper.stub_body("api/v1/test_runners/abc123", {})
      allow(test_runner).to receive(:ip_address).and_return(nil, "111.11.11.1")
      allow(test_runner).to receive(:rsa_key_path).and_return("/tmp/saturnci/test-runner-abc123")
    end

    it "outputs a message" do
      expect do
        command = "--test-runner abc123 ssh"
        client.ssh(test_runner)
      end.to output("Waiting for IP address...\nssh -o StrictHostKeyChecking=no -i /tmp/saturnci/test-runner-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  describe "terminate on completion" do
    before do
      allow(test_runner).to receive(:ip_address).and_return("111.11.11.1")
      allow(test_runner).to receive(:rsa_key_path).and_return("/tmp/saturnci/test-runner-abc123")
    end

    it "sends a request to set terminate_on_completion to false" do
      client.ssh(test_runner)

      expect(a_request(:patch, "https://app.saturnci.com/api/v1/test_runners/abc123"))
        .to have_been_made.once
    end
  end
end
