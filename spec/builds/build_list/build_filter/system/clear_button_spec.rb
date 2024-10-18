require "rails_helper"

describe "Clearing filter selections", type: :system do
  let!(:project) { create(:project) }

  context "branch selection" do
    before do
      create(
        :build,
        :with_job,
        project: project,
        branch_name: "main",
        commit_message: "Commit from 'main' branch"
      )

      create(
        :build,
        :with_job,
        project: project,
        branch_name: "filters",
        commit_message: "Commit from 'filter' branch"
      )

      user = create(:user)
      login_as(user, scope: :user)
    end

    it "clears branch selection" do
      visit project_path(project)

      select "main", from: "branch_name"
      click_button "Apply"

      # To prevent race condition
      within ".build-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      click_button "Clear"

      within ".build-list" do
        expect(page).to have_content("Commit from 'filter' branch")
      end
    end
  end

  context "status selection" do
    let!(:failed_build) do
      create(
        :build,
        :with_job,
        cached_status: "Failed",
        commit_message: "This branch failed"
      )
    end

    let!(:passed_build) do
      create(
        :build,
        :with_job,
        cached_status: "Passed",
        project: failed_build.project,
        commit_message: "This branch passed"
      )
    end

    before do
      user = create(:user)
      login_as(user, scope: :user)
    end

    it "clears status selection" do
      visit project_path(failed_build.project)

      check "Passed"
      click_button "Apply"
      expect(page).not_to have_content("This branch failed")

      click_button "Clear"
      expect(page).to have_content("This branch failed")
    end
  end
end