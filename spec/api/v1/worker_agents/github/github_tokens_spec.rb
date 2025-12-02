require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub tokens", type: :request do
  describe "POST /api/v1/worker_agents/github_tokens" do
    let!(:test_runner) { create(:test_runner) }

    it "returns a token" do
      allow(GitHubToken).to receive(:generate).and_return("ABC123")

      post(api_v1_worker_agents_github_tokens_path, headers: worker_agents_api_authorization_headers(test_runner))
      expect(response.body).to eq("ABC123")
    end
  end
end
