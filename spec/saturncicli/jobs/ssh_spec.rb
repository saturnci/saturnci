require "rails_helper"
require_relative "../helpers/authentication_helper"
require_relative "../../../lib/saturncicli/client"

describe "ssh" do
  it "works" do
    job = create(:job)

    AuthenticationHelper.stub_authentication_request
    client = SaturnCICLI::Client.new(
      username: "valid_username",
      password: "valid_password"
    )

    expect {
      command = "--job #{job.id} ssh"
      client.execute(command)
    }.to output("#{job.id}\n").to_stdout
  end
end
