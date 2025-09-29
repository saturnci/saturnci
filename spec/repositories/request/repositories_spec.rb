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
