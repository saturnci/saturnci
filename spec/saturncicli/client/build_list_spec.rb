require_relative "../../../lib/saturncicli/client"

describe "build list" do
  before do
    body = [
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "7f8c8132",
        "commit_message" => "Fix response.body issue in SaturnCI client."
      },
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "b7ef6ce6",
        "commit_message" => "Fix credentials issue."
      },
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "650f5674",
        "commit_message" => "Make output more elegant."
      }
    ].to_json

    stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/api/v1/builds")
      .to_return(body: body, status: 200)
  end

  let!(:client) do
    SaturnCICLI::Client.new(
      username: "valid_username",
      password: "valid_password"
    )
  end

  it "formats the output to a table" do
    expected_output = <<~OUTPUT
    Branch           Commit    Commit message
    saturnci-client  7f8c8132  Fix response.body issue in SaturnCI clien...
    saturnci-client  b7ef6ce6  Fix credentials issue.
    saturnci-client  650f5674  Make output more elegant.
    OUTPUT

    expect { client.builds }.to output(expected_output).to_stdout
  end
end