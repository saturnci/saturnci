require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test runner list" do
  before do
    body = [
      {
        "id" => "da9b6c0f-e5d9-4d2f-b4a1-d7e0a2b9c1d0",
        "name" => "test-runner-f60ca0ad-89c8-440e-9373-ed639d2dd662",
        "cloud_id" => "8923489234"
      },
      {
        "id" => "669b6c0f-e5d9-4d2f-b4a1-d7e0a2b9c1d0",
        "name" => "test-runner-9f60ca0ad-89c8-440e-9373-ed639d2dd662",
        "cloud_id" => "2889234892"
      },
      {
        "id" => "a69b6c0f-e5d9-4d2f-b4a1-d7e0a2b9c1d0",
        "name" => "test-runner-ac60ca0ad-89c8-440e-9373-ed639d2dd662",
        "cloud_id" => "3892348923"
      }
    ].to_json

    stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_runners")
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
    ID        Name                      Cloud ID
    da9b6c0f  test-runner-f60ca0ad-...  8923489234
    669b6c0f  test-runner-9f60ca0ad...  2889234892
    a69b6c0f  test-runner-ac60ca0ad...  3892348923
    OUTPUT

    expect {
      client.test_runners
    }.to output(expected_output).to_stdout
  end
end
