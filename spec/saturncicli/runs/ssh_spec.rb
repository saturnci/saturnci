require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  before do
    AuthenticationHelper.stub_authentication_request
    allow_any_instance_of(SaturnCICLI::SSHSession).to receive(:connect)
  end

  let!(:client) do
    SaturnCICLI::Client.new(
      username: "valid_username",
      password: "valid_password"
    )
  end

  let!(:connection_details) do
    instance_double(SaturnCICLI::ConnectionDetails)
  end

  before do
    allow(connection_details).to receive(:refresh).and_return(connection_details)
  end

  context "remote machine has an IP address" do
    let!(:body) do
      { "ip_address" => "111.11.11.1" }
    end

    before do
      APIHelper.stub_body("api/v1/runs/abc123", body)
      allow(connection_details).to receive(:ip_address).and_return("111.11.11.1")
      allow(connection_details).to receive(:rsa_key_path).and_return("/tmp/saturnci/run-abc123")
    end

    it "outputs the run id" do
      expect do
        command = "--run abc123 ssh"
        client.ssh("abc123", connection_details)
      end.to output("ssh -o StrictHostKeyChecking=no -i /tmp/saturnci/run-abc123 root@111.11.11.1\n").to_stdout
    end
  end

  context "remote machine does not yet have an IP address" do
    before do
      APIHelper.stub_body("api/v1/runs/abc123", {})
      allow(connection_details).to receive(:ip_address).and_return(nil, "111.11.11.1")
      allow(connection_details).to receive(:rsa_key_path).and_return("/tmp/saturnci/run-abc123")
    end

    it "outputs a dot" do
      expect do
        command = "--run abc123 ssh"
        client.ssh("abc123", connection_details)
      end.to output(".ssh -o StrictHostKeyChecking=no -i /tmp/saturnci/run-abc123 root@111.11.11.1\n").to_stdout
    end
  end
end
