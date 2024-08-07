require "rails_helper"

describe "Filter", type: :system do
  let!(:project) { create(:project) }

  before do
    create(:build, :with_job, project: project, branch_name: "main", commit_message: "Main commit")
    create(:build, :with_job, project: project, branch_name: "filters", commit_message: "Filter commit")

    user = create(:user)
    login_as(user, scope: :user)
  end

  context "main branch" do
    it "only shows builds from the main branch" do
      visit project_path(project)

      select "main", from: "branch_name"
      click_button "Apply"

      within ".build-list" do
        expect(page).not_to have_content("Filter commit")
      end
    end

    it "includes all branches as an option even after selection" do
      visit project_path(project)

      select "main", from: "branch_name"
      click_button "Apply"

      within ".build-list" do
        expect(page).not_to have_content("Filter commit")
      end

      expect(page).to have_select("branch_name", with_options: ["main", "filters"])
    end
  end

  context "filters branch" do
    it "only shows builds from the filters branch" do
      visit project_path(project)

      select "filters", from: "branch_name"
      click_button "Apply"

      within ".build-list" do
        expect(page).not_to have_content("Main commit")
      end
    end
  end
end
