require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  let!(:body) do
    {
      "job_machine_rsa_key_path" => "/tmp/saturnci/job-abc123",
      "ip_address" => "111.11.11.1"
    }
  end

  before do
    AuthenticationHelper.stub_authentication_request
    APIHelper.stub_body("api/v1/jobs/abc123", body)
    allow_any_instance_of(SSHSession).to receive(:connect)
  end

  let!(:client) do
    SaturnCICLI::Client.new(
      username: "valid_username",
      password: "valid_password"
    )
  end

  it "outputs the job id" do
    expect {
      command = "--job abc123 ssh"
      client.execute(command)
    }.to output("ssh -i /tmp/saturnci/job-abc123 root@111.11.11.1\n").to_stdout
  end
end
