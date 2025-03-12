require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test runner list" do
  before do
    body = [
      {
        "id" => "a68c4aef-de05-4a14-a274-207d7e81bee9",
        "name" => "tr-5ab042f8-toxic-manager",
        "cloud_id" => "482333509"
      },
      {
        "id" => "bb4d0342-d32f-462a-b21c-3cddefb7b74d",
        "name" => "tr-a4c47d49-magical-lobster",
        "cloud_id" => "482333508"
      },
      {
        "id" => "7abd6b84-2da2-4273-994b-d3496f6684db",
        "name" => "tr-f66f0860-secret-grape",
        "cloud_id" => "482222371"
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
    ID        Name                         Cloud ID
    a68c4aef  tr-5ab042f8-toxic-manager    482333509
    bb4d0342  tr-a4c47d49-magical-lobster  482333508
    7abd6b84  tr-f66f0860-secret-grape     482222371
    OUTPUT
    expect {
      client.test_runners
    }.to output(expected_output).to_stdout
  end
end
