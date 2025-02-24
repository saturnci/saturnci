require "rails_helper"

describe "Branch filtering", type: :system do
  let!(:project) { create(:project) }

  before do
    create(
      :build,
      :with_run,
      project: project,
      branch_name: "main",
      commit_message: "Commit from 'main' branch"
    )

    create(
      :build,
      :with_run,
      project: project,
      branch_name: "filters",
      commit_message: "Commit from 'filter' branch"
    )

    login_as(project.user, scope: :user)
  end

  context "main branch is selected" do
    before do
      visit project_path(project)
      click_on "Filters"

      select "main", from: "branch_name"
      click_button "Apply"
      click_on "Filters"
    end

    it "only shows builds from the main branch" do
      within ".build-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end
    end

    it "includes all branches as an option even after selection" do
      within ".build-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      expect(page).to have_select("branch_name", with_options: ["main", "filters"])
    end

    it "keeps 'main' selected" do
      # To prevent race condition
      within ".build-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      expect(find_field("branch_name").value).to eq("main")
    end
  end

  context "filters branch is selected" do
    it "only shows builds from the filters branch" do
      visit project_path(project)

      click_on "Filters"
      select "filters", from: "branch_name"
      click_button "Apply"
      click_on "Filters"

      within ".build-list" do
        expect(page).not_to have_content("Commit from 'main' branch")
      end
    end
  end
end
