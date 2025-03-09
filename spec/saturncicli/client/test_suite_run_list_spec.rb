require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test suite run list" do
  before do
    body = [
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "2bfcb64c87d9dbdd2bfa8afb0990f73213aa0ee3",
        "commit_message" => "Fix response.body issue in SaturnCI client."
      },
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "ede26ec569c4be5b32a091bcf289ce8419482733",
        "commit_message" => "Fix credentials issue."
      },
      {
        "branch_name" => "saturnci-client",
        "commit_hash" => "f8244ef37de599a165fd7690aa9619bea67236a1",
        "commit_message" => "Make output more elegant."
      }
    ].to_json

    stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_suite_runs")
      .to_return(body: body, status: 200)
  end

  let!(:client) do
    credential = SaturnCICLI::Credential.new(
      user_id: "valid_user_id",
      api_token: "valid_api_token"
    )

    SaturnCICLI::Client.new(credential)
  end

  it "formats the output to a table" do
    expected_output = <<~OUTPUT
    Branch           Commit    Commit message
    saturnci-client  2bfcb64c  Fix response.body iss...
    saturnci-client  ede26ec5  Fix credentials issue...
    saturnci-client  f8244ef3  Make output more eleg...
    OUTPUT

    expect {
      client.test_suite_runs(columns: %w[branch_name commit_hash commit_message])
    }.to output(expected_output).to_stdout
  end
end
