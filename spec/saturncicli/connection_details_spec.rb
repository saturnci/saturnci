require "rails_helper"

describe SaturnCICLI::ConnectionDetails do
  describe "#rsa_key_path" do
    let!(:connection_details) do
      SaturnCICLI::ConnectionDetails.new(
        request: -> do
          double(
            "Response",
            body: { rsa_key: Base64.encode64("FAKE_RSA_KEY_CONTENT") }.to_json
          )
        end
      )
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
