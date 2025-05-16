require "rails_helper"

describe "GitHub token", type: :request do
  let!(:user) { create(:user) }

  context "user has GitHub token" do
    before do
      allow(user).to receive(:github_repositories).and_return(Repository.none)
      login_as(user)
    end

    it "does not redirect" do
      get repositories_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "user does not have GitHub token" do
    before do
      allow(user).to receive(:can_hit_github_api?).and_return(false)
      login_as(user)
    end

    it "redirects" do
      get repositories_path
      expect(response).to have_http_status(:found)
    end
  end
end
