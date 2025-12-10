require "rails_helper"

describe "Clearing filter selections", type: :system do
  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
  end

  context "branch selection" do
    before do
      create(
        :test_suite_run,
        :with_passed_run,
        repository: repository,
        branch_name: "main",
        commit_message: "Commit from 'main' branch"
      )

      create(
        :test_suite_run,
        :with_passed_run,
        repository: repository,
        branch_name: "filters",
        commit_message: "Commit from 'filter' branch"
      )

      login_as(repository.user)
    end

    it "clears branch selection" do
      visit repository_path(repository)

      click_on "Filters"
      select "main", from: "branch_name"
      click_button "Apply"
      click_on "Filters"

      # To prevent race condition
      within ".test-suite-run-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      click_button "Clear"

      within ".test-suite-run-list" do
        expect(page).to have_content("Commit from 'filter' branch")
      end
    end
  end

  context "status selection" do
    let!(:failed_test_suite_run) do
      create(
        :test_suite_run,
        :with_failed_run,
        cached_status: "Failed",
        commit_message: "This branch failed"
      )
    end

    let!(:passed_test_suite_run) do
      create(
        :test_suite_run,
        :with_passed_run,
        cached_status: "Passed",
        repository: failed_test_suite_run.repository,
        commit_message: "This branch passed"
      )
    end

    before do
      login_as(failed_test_suite_run.repository.user)
    end

    it "clears status selection" do
      visit repository_path(failed_test_suite_run.repository)

      click_on "Filters"
      check "Passed"
      click_button "Apply"
      click_on "Filters"
      expect(page).not_to have_content("This branch failed")

      click_button "Clear"
      click_on "Filters"
      expect(page).to have_content("This branch failed")
    end
  end
end
