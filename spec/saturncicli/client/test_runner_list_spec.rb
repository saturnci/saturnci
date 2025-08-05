require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "test runner list" do
  before do
    body = [
      {
        "id" => "a68c4aef-de05-4a14-a274-207d7e81bee9",
        "created_at" => "2023-10-01T00:00:00Z",
        "name" => "tr-5ab042f8-toxic-manager",
        "status" => "Provisioning",
        "repository_name" => "my-repo",
      },
      {
        "id" => "bb4d0342-d32f-462a-b21c-3cddefb7b74d",
        "created_at" => "2023-10-01T00:00:00Z",
        "name" => "tr-a4c47d49-magical-lobster",
        "status" => "Provisioning",
        "repository_name" => "another-repo",
      },
      {
        "id" => "7abd6b84-2da2-4273-994b-d3496f6684db",
        "created_at" => "2023-10-01T00:00:00Z",
        "name" => "tr-f66f0860-secret-grape",
        "status" => "Provisioning",
        "repository_name" => nil,
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
    ID        Created at           Name                         Status        Run ID  Repository    Commit message
    a68c4aef  2023-10-01 00:00:00  tr-5ab042f8-toxic-manager    Provisioning          my-repo
    bb4d0342  2023-10-01 00:00:00  tr-a4c47d49-magical-lobster  Provisioning          another-repo
    7abd6b84  2023-10-01 00:00:00  tr-f66f0860-secret-grape     Provisioning
    OUTPUT
    expect {
      client.test_runners
    }.to output(expected_output).to_stdout
  end
end
