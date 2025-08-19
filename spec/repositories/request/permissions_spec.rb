require "rails_helper"

describe "Repository permissions", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }
  let!(:repository) { test_suite_run.repository }

  describe "GET repository" do
    context "not signed in" do
      it "gives a 404" do
        get project_path(repository)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "one's own repository" do
      before do
        login_as(repository.user)
      end

      it "gives a 302" do
        get project_path(repository)
        expect(response).to have_http_status(:found)
      end
    end

    context "somebody else's repository" do
      before do
        login_as(create(:user))
      end

      it "gives a 404" do
        get project_path(repository)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "user with expired GitHub token" do
      let!(:user_with_expired_token) { create(:user) }
      let!(:github_client) { instance_double(GitHubClient) }

      before do
        login_as(user_with_expired_token)
        
        # Mock GitHubClient to raise Octokit::Unauthorized when accessing repositories
        allow(GitHubClient).to receive(:new).with(user_with_expired_token).and_return(github_client)
        allow(github_client).to receive(:repositories)
          .and_raise(Octokit::Unauthorized.new)
      end

      it "redirects to GitHub OAuth when GitHub API authentication fails" do
        get repositories_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
