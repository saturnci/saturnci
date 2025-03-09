require_relative "../../lib/saturncicli/credential"
require_relative "../../lib/saturncicli/api_request"

describe SaturnCICLI::APIRequest do
  context "host is https" do
    let!(:credential) do
      SaturnCICLI::Credential.new(
        host: "https://app.saturnci.com",
        user_id: "valid_user_id",
        api_token: "valid_api_token"
      )
    end

    it "uses SSL" do
      api_request = SaturnCICLI::APIRequest.new(
        credential:,
        method: "GET",
        endpoint: "test_suite_runs"
      )

      expect(api_request.use_ssl?).to be true
    end
  end

  context "host is http" do
    let!(:credential) do
      SaturnCICLI::Credential.new(
        host: "http://localhost:3000",
        user_id: "valid_user_id",
        api_token: "valid_api_token"
      )
    end

    it "does not use SSL" do
      api_request = SaturnCICLI::APIRequest.new(
        credential:,
        method: "GET",
        endpoint: "test_suite_runs"
      )

      expect(api_request.use_ssl?).to be false
    end
  end
end
