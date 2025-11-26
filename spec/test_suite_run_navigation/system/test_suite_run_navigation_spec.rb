require "rails_helper"

describe "Test suite run navigation", type: :system do
  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    allow_any_instance_of(TestSuiteRun).to receive(:check_test_case_run_integrity!)
  end

  describe "test suite run link destination" do
    include SaturnAPIHelper

    context "test suite run went from running to finished" do
      let!(:run) { create(:run, :with_test_runner) }
      let!(:test_suite_run_link) { PageObjects::TestSuiteRunLink.new(page, run.test_suite_run) }

      before do
        login_as(run.repository.user)
        visit repository_test_suite_run_path(run.repository, run.test_suite_run)
      end

      it "stays selected after refresh" do
        expect(page).to have_content("Running")

        test_suite_run_link.click

        http_request(
          api_authorization_headers: test_runner_agents_api_authorization_headers(run.test_runner),
          path: api_v1_test_runner_agents_run_run_finished_events_path(run_id: run.id, format: :json)
        )
        expect(page).to have_content("Failed") # to prevent race condition

        test_suite_run_link.click
        expect(test_suite_run_link).to be_active
      end
    end
  end

  describe "clicking on second test suite run after having visited first test suite run" do
    let!(:first_test_suite_run) { create(:test_suite_run, :with_run) }
    let!(:second_test_suite_run) { create(:test_suite_run, :with_run, repository: first_test_suite_run.repository) }

    before do
      login_as(first_test_suite_run.repository.user)
    end

    before do
      visit repository_test_suite_run_path(first_test_suite_run.repository, first_test_suite_run)
      click_on "test_suite_run_link_#{second_test_suite_run.id}"
      expect(page).to have_content(pane_heading(second_test_suite_run)) # to prevent race condition
    end

    it "retains the first test suite run in the test suite run list" do
      expect(page).to have_content(first_test_suite_run.repository.name)
    end

    it "after refresh, keeps second test suite run in detail pane" do
      visit current_url
      expect(page).to have_content(pane_heading(second_test_suite_run))
    end

    it "after refresh, keeps left pane (test suite run list)" do
      visit current_url
      expect(page).to have_content(first_test_suite_run.repository.name)
    end

    def pane_heading(test_suite_run)
      "Commit: #{test_suite_run.commit_hash[0..7]}"
    end
  end
end
