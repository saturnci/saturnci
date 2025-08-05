require "rails_helper"

describe "Repository access", type: :system do
  let!(:user) { create(:user) }
  let!(:github_client) { instance_double(GitHubClient) }

  let!(:repository) do
    create(:repository, name: "panda", github_repo_full_name: "panda")
  end

  before do
    allow(GitHubClient).to receive(:new).with(user).and_return(github_client)
    login_as(user)
  end

  context "GitHub OAuth token is valid" do
    context "user has access" do
      before do
        allow(github_client).to receive(:repositories).and_return(Repository.all)
      end

      it "shows the repository" do
        visit repositories_path
        expect(page).to have_content("panda")
      end
    end

    context "user does not have access" do
      before do
        allow(github_client).to receive(:repositories).and_return(Repository.none)
      end

      it "does not show the repository" do
        visit repositories_path
        expect(page).not_to have_content("panda")
      end
    end
  end
end
