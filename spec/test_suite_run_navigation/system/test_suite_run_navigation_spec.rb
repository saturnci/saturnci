require "rails_helper"

describe "Test suite run navigation", type: :system do
  describe "test suite run link destination" do
    include SaturnAPIHelper

    context "test suite run went from running to finished" do
      let!(:run) { create(:run) }
      let!(:test_suite_run_link) { PageObjects::TestSuiteRunLink.new(page, run.test_suite_run) }

      before do
        login_as(run.project.user)
        visit project_build_path(run.project, run.test_suite_run)
      end

      it "links to the overview page" do
        expect(page).to have_content("Running")
        http_request(
          api_authorization_headers: api_authorization_headers(run.project.user),
          path: api_v1_run_run_finished_events_path(run_id: run.id, format: :json)
        )
        expect(page).to have_content("Failed") # to prevent race condition
        create(:test_case_run, run:)

        test_suite_run_link.click
        expect(page).to have_content("1 test case, 0 failed")
      end

      it "stays selected after refresh" do
        expect(page).to have_content("Running")

        test_suite_run_link.click

        http_request(
          api_authorization_headers: api_authorization_headers(run.project.user),
          path: api_v1_run_run_finished_events_path(run_id: run.id, format: :json)
        )
        expect(page).to have_content("Failed") # to prevent race condition

        test_suite_run_link.click
        expect(test_suite_run_link).to be_active
      end
    end
  end

  describe "clicking on second test suite run after having visited first test suite run" do
    let!(:first_test_suite_run) { create(:build, :with_run) }
    let!(:second_test_suite_run) { create(:build, :with_run, project: first_test_suite_run.project) }

    before do
      login_as(first_test_suite_run.project.user)
    end

    before do
      visit project_build_path(first_test_suite_run.project, first_test_suite_run)
      click_on "test_suite_run_link_#{second_test_suite_run.id}"
      expect(page).to have_content(pane_heading(second_test_suite_run)) # to prevent race condition
    end

    it "retains the first test suite run in the test suite run list" do
      expect(page).to have_content(first_test_suite_run.project.name)
    end

    it "after refresh, keeps second test suite run in detail pane" do
      visit current_url
      expect(page).to have_content(pane_heading(second_test_suite_run))
    end

    it "after refresh, keeps left pane (test suite run list)" do
      visit current_url
      expect(page).to have_content(first_test_suite_run.project.name)
    end

    def pane_heading(test_suite_run)
      "Commit: #{test_suite_run.commit_hash[0..7]}"
    end
  end
end
