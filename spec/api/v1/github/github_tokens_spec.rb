require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub tokens", type: :request do
  describe "POST /api/v1/github_tokens" do
    it "returns a token" do
      allow(GitHubToken).to receive(:generate).and_return("ABC123")

      post(api_v1_github_tokens_path, headers: api_authorization_headers)
      expect(response.body).to eq("ABC123")
    end
  end
end
