require "rails_helper"

describe "Show new test suite run", type: :system do
  include SaturnAPIHelper

  context "test suite run created via API" do
    let!(:repository) { create(:repository, github_repo_full_name: "jasonswett/panda") }
    let!(:test_suite_run) { create(:test_suite_run, repository: repository) }
    let!(:personal_access_token) { create(:personal_access_token, user: repository.user) }

    before do
      allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
      login_as(repository.user)
      visit repository_path(repository)
    end

    it "shows the new test suite run" do
      within ".test-suite-run-list" do
        expect(page).to have_content(test_suite_run.commit_hash)
      end

      http_request(
        api_authorization_headers: api_authorization_headers(personal_access_token),
        path: api_v1_test_suite_runs_path(
          repository: "jasonswett/panda",
          commit_hash: "abc123",
          branch_name: "main",
          commit_message: "Test commit",
          author_name: "Test Author"
        )
      )

      within ".test-suite-run-list" do
        expect(page).to have_content("THIS_WILL_NOT_BE_FOUND_307")
      end
    end
  end
end
