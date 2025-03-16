require "rails_helper"
require Rails.root.join("lib/saturncicli/test_runner")

describe SaturnCICLI::TestRunner do
  describe "#rsa_key_path" do
    let!(:test_runner) do
      response = double(
        "Response",
        body: { rsa_key: Base64.encode64("FAKE_RSA_KEY_CONTENT") }.to_json
      )

      allow(response).to receive(:code).and_return("200")

      SaturnCICLI::TestRunner.new(
        id: "abc123",
        readiness_check_request: -> { response }
      )
    end

    it "returns a path" do
      test_runner.refresh
      expect(test_runner.rsa_key_path).to be_present
    end

    it "puts the key in a file" do
      test_runner.refresh
      expect(File.read(test_runner.rsa_key_path)).to eq("FAKE_RSA_KEY_CONTENT")
    end
  end
end
