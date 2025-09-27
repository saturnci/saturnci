require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test runner delete --all" do
  let!(:client) do
    credential = SaturnCICLI::Credential.new(
      user_id: "valid_user_id",
      api_token: "valid_api_token"
    )
    SaturnCICLI::Client.new(credential)
  end

  it "makes a DELETE request to test_runner_collection endpoint" do
    stub = stub_request(:delete, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_runner_collection")
      .to_return(status: 204)

    client.execute([:delete_all_test_runners])

    expect(stub).to have_been_requested
  end
end
