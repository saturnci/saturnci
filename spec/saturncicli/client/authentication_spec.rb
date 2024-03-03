require_relative '../../../lib/saturncicli/client'

describe "authentication" do
  context "valid credentials" do
    it "does not raise an error" do
      stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/api/v1/builds")
        .to_return(body: "[]", status: 200)

      expect {
        SaturnCICLI::Client.new(
          username: "valid_username",
          password: "valid_password"
        )
      }.not_to raise_error
    end
  end

  context "invalid credentials" do
    it "outputs a graceful error message" do
      stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/api/v1/builds")
        .to_return(status: 401)

      expect {
        SaturnCICLI::Client.new(
          username: "",
          password: ""
        )
      }.to raise_error("Bad credentials.")
    end
  end

  context "raw error" do
    it "does not raise a bad credentials error" do
      stub_request(:get, "#{SaturnCICLI::Client::DEFAULT_HOST}/api/v1/builds")
        .to_return(status: 500)

      expect {
        SaturnCICLI::Client.new(
          username: "",
          password: ""
        )
      }.not_to raise_error
    end
  end
end
