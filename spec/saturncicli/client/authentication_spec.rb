require_relative "../../../lib/saturncicli/credential"
require_relative "../../../lib/saturncicli/client"

describe "authentication" do
  context "valid credentials" do
    let!(:credential) do
      SaturnCICLI::Credential.new(
        user_id: "valid_user_id",
        api_token: "valid_api_token"
      )
    end

    it "does not raise an error" do
      stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/builds")
        .to_return(body: "[]", status: 200)

      expect {
        SaturnCICLI::Client.new(credential)
      }.not_to raise_error
    end
  end

  context "invalid credentials" do
    let!(:credential) do
      SaturnCICLI::Credential.new(
        user_id: "",
        api_token: ""
      )
    end

    let!(:client) do
      SaturnCICLI::Client.new(credential)
    end

    it "outputs a graceful error message" do
      stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/builds")
        .to_return(status: 401)

      expect { client.builds }.to raise_error("Bad credentials.")
    end
  end

  context "raw error" do
    let!(:credential) do
      SaturnCICLI::Credential.new(
        user_id: "",
        api_token: ""
      )
    end

    it "does not raise a bad credentials error" do
      stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/builds")
        .to_return(status: 500)

      expect {
        SaturnCICLI::Client.new(credential)
      }.not_to raise_error
    end
  end
end
