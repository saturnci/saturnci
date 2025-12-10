require "rails_helper"

describe "Branch filtering", type: :system do
  let!(:repository) { create(:repository) }

  before do
    create(
      :test_suite_run,
      :with_run,
      repository: repository,
      branch_name: "main",
      commit_message: "Commit from 'main' branch"
    )

    create(
      :test_suite_run,
      :with_run,
      repository: repository,
      branch_name: "filters",
      commit_message: "Commit from 'filter' branch"
    )

    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(repository.user)
  end

  context "main branch is selected" do
    before do
      visit repository_path(repository)
      click_on "Filters"

      select "main", from: "branch_name"
      click_button "Apply"
      click_on "Filters"
    end

    it "only shows test suite runs from the main branch" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end
    end

    it "includes all branches as an option even after selection" do
      within ".test-suite-run-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      expect(page).to have_select("branch_name", with_options: ["main", "filters"])
    end

    it "keeps 'main' selected" do
      # To prevent race condition
      within ".test-suite-run-list" do
        expect(page).not_to have_content("Commit from 'filter' branch")
      end

      expect(find_field("branch_name").value).to eq("main")
    end
  end

  context "filters branch is selected" do
    it "only shows test suite runs from the filters branch" do
      visit repository_path(repository)

      click_on "Filters"
      select "filters", from: "branch_name"
      click_button "Apply"
      click_on "Filters"

      within ".test-suite-run-list" do
        expect(page).not_to have_content("Commit from 'main' branch")
      end
    end
  end
end
