require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  let!(:body) do
    { "id" => "abc123" }
  end

  before do
    AuthenticationHelper.stub_authentication_request
    APIHelper.stub_body("api/v1/jobs/abc123", body)
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
    }.to output("#{body.to_s}\n").to_stdout
  end
end
