require "rails_helper"

describe "Repository access", type: :system do
  let!(:user) { create(:user) }
  let!(:github_client) { instance_double(Octokit::Client) }

  let!(:repository) do
    create(:repository, name: "panda", github_repo_full_name: "panda")
  end

  context "GitHub OAuth token is valid" do
    before do
      allow(github_client).to receive(:user)
      allow(user).to receive(:github_client).and_return(github_client)
    end

    context "user has access" do
      before do
        allow(user).to receive(:github_repositories).and_return([repository])
        login_as(user)
      end

      it "shows the repository" do
        visit repositories_path
        expect(page).to have_content("panda")
      end
    end

    context "user does not have access" do
      before do
        allow(user).to receive(:github_repositories).and_return([])
        login_as(user)
      end

      it "does not show the repository" do
        visit repositories_path
        expect(page).not_to have_content("panda")
      end
    end
  end

  context "GitHub OAuth token is invalid" do
    before do
      allow(github_client).to receive(:user)
      allow(user).to receive(:github_client).and_raise(Octokit::Unauthorized)
      login_as(user)
    end

    it "redirects to the sign in page" do
      visit repositories_path
      expect(page).to have_content("Sign in")
    end
  end
end
