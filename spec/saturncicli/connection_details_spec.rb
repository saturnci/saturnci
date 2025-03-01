require "rails_helper"
require Rails.root.join("lib/saturncicli/connection_details")

describe SaturnCICLI::ConnectionDetails do
  describe "#rsa_key_path" do
    let!(:connection_details) do
      response = double(
        "Response",
        body: { rsa_key: Base64.encode64("FAKE_RSA_KEY_CONTENT") }.to_json
      )

      allow(response).to receive(:code).and_return("200")

      SaturnCICLI::ConnectionDetails.new(request: -> { response })
    end

    it "returns a path" do
      connection_details.refresh
      expect(connection_details.rsa_key_path).to be_present
    end

    it "puts the key in a file" do
      connection_details.refresh
      expect(File.read(connection_details.rsa_key_path)).to eq("FAKE_RSA_KEY_CONTENT")
    end
  end
end
