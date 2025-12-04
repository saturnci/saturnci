require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub tokens", type: :request do
  describe "POST /api/v1/worker_agents/github_tokens" do
    let!(:worker) { create(:worker) }

    it "returns a token" do
      allow(GitHubToken).to receive(:generate).and_return("ABC123")

      post(api_v1_worker_agents_github_tokens_path, headers: worker_agents_api_authorization_headers(worker))
      expect(response.body).to eq("ABC123")
    end
  end
end
