require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "debug messages", type: :request do
  describe "POST /api/v1/debug_messages" do
    let!(:build) { create(:build) }

    it "logs the message" do
      allow(Rails.logger).to receive(:info)

      post(
        api_v1_debug_messages_path,
        params: "answer: 42",
        headers: api_authorization_headers(build).merge("CONTENT_TYPE" => "text/plain")
      )

      expect(Rails.logger).to have_received(:info).with("answer: 42")
    end
  end
end
