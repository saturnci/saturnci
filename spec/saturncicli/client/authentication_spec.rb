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
      stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/test_suite_runs")
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

    it "returns false" do
      stub_request(:get, "#{SaturnCICLI::Credential::DEFAULT_HOST}/api/v1/runs")
        .to_return(status: 401, body: {}.to_json)

      expect(credential.valid?).to be false
    end
  end
end
