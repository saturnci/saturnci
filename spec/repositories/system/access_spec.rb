require "rails_helper"

describe "Repository access", type: :system do
  let!(:user) { create(:user) }

  let!(:repository) do
    create(:repository, name: "panda", github_repo_full_name: "panda")
  end

  context "GitHub OAuth token is valid" do
    context "user has access" do
      before do
        allow(user).to receive(:github_repositories).and_return(Repository.all)
        login_as(user)
      end

      it "shows the repository" do
        visit repositories_path
        expect(page).to have_content("panda")
      end
    end

    context "user does not have access" do
      before do
        allow(user).to receive(:github_repositories).and_return(Repository.none)
        login_as(user)
      end

      it "does not show the repository" do
        visit repositories_path
        expect(page).not_to have_content("panda")
      end
    end
  end
end
