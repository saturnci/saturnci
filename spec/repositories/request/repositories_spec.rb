require "rails_helper"

describe "Repositories", type: :request do
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

    context "when there is no test suite run" do
      let!(:repository) { create(:repository) }

      before do
        login_as(repository.user, scope: :user)
        # Stub the authorization check to avoid GitHub API calls
        allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)

        allow(TestSuiteRunFromCommitFactory).to receive(:most_recent_commit).and_return(
          {
            "sha" => "d9e65e719b3fffae853d6264485d3f0467b3d8a3",
            "commit" => {
              "author" => {
                "name" => "Jason Swett",
              },
              "message" => "Change stuff.",
            }
          }
        )
      end

      context "there have never been test suite runs before" do
        it "creates a test suite run" do
          expect {
            get repository_path(repository)
          }.to change(TestSuiteRun, :count).by(1)
        end
      end

      context "there are test suite runs for other repositories" do
        before { create(:test_suite_run) }

        it "creates a test suite run" do
          expect {
            get repository_path(repository)
          }.to change(TestSuiteRun, :count).by(1)
        end
      end

      context "there have been test suite runs before" do
        before do
          create(:test_suite_run, repository:).destroy
        end

        it "creates a test suite run" do
          expect {
            get repository_path(repository)
          }.to change(TestSuiteRun, :count).by(1)
        end
      end
    end
  end
end
