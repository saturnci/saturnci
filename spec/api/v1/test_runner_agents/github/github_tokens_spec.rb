require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub tokens", type: :request do
  describe "POST /api/v1/test_runner_agents/github_tokens" do
    let!(:user) { create(:user) }

    it "returns a token" do
      allow(GitHubToken).to receive(:generate).and_return("ABC123")

      post(api_v1_test_runner_agents_github_tokens_path, headers: api_authorization_headers(user))
      expect(response.body).to eq("ABC123")
    end
  end
end
