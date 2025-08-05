require "rails_helper"

describe "Repositories", type: :request do
  describe "GET /repositories" do
    it "returns 200" do
      user = create(:user)
      allow(user).to receive(:github_repositories).and_return(Repository.none)
      login_as(user)
      get repositories_path
      expect(response).to have_http_status(200)
    end
  end
end
