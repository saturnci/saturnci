require "rails_helper"

describe "Repositories", type: :request do
  describe "GET /repositories" do
    let!(:user) { create(:user) }
    let!(:github_client) { instance_double(GitHubClient) }

    before do
      allow(GitHubClient).to receive(:new).with(user).and_return(github_client)
      allow(github_client).to receive(:repositories).and_return(Repository.none)
      login_as(user)
    end

    it "returns 200" do
      get repositories_path
      expect(response).to have_http_status(200)
    end
  end
end
