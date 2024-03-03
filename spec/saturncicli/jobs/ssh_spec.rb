require "rails_helper"
require_relative "../helpers/authentication_helper"
require_relative "../helpers/api_helper"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  it "works" do
    AuthenticationHelper.stub_authentication_request
    client = SaturnCICLI::Client.new(
      username: "valid_username",
      password: "valid_password"
    )

    APIHelper.stub_body("api/v1/job/abc123", {
      id: "abc123"
    }.to_json)

    expect {
      command = "--job abc123 ssh"
      client.execute(command)
    }.to output("abc123\n").to_stdout
  end
end
