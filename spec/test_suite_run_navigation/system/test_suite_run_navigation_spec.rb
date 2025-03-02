require "rails_helper"

describe "Test suite run navigation", type: :system do
  describe "clicking on second test suite run after having visited first test suite run" do
    let!(:first_test_suite_run) { create(:build, :with_run) }
    let!(:second_test_suite_run) { create(:build, :with_run, project: first_test_suite_run.project) }

    before do
      login_as(first_test_suite_run.project.user, scope: :user)
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
