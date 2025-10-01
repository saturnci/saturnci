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

  describe "GET /repositories/new" do
    let!(:user) { create(:user) }

    before do
      login_as(user)
    end

    context "when GitHub API returns unauthorized" do
      before do
        github_client = instance_double(GitHubClient)
        allow(GitHubClient).to receive(:new).with(user).and_return(github_client)
        allow(github_client).to receive(:octokit_repositories).and_raise(Octokit::Unauthorized)
      end

      it "redirects to sign in page" do
        get new_repository_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "signs the user out" do
        get new_repository_path
        expect(controller.current_user).to be_nil
      end
    end
  end

  describe "GET repository" do
    context "when there is a test suite run" do
      let!(:test_suite_run) { create(:test_suite_run) }

      before do
        allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
        login_as(test_suite_run.repository.user)
      end

      it "redirects to the test suite run" do
        get repository_path(test_suite_run.repository)

        expect(response).to redirect_to(TestSuiteRunLinkPath.new(test_suite_run).value)
      end
    end

  end
end
