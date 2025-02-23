require "rails_helper"

describe "Showing and hiding filters", type: :system do
  let!(:build) { create(:build) }

  before do
    login_as(build.project.user)
    visit project_build_path(id: build.id, project_id: build.project.id)
  end

  describe "Hiding filters" do
    before { click_on "Filters" }

    it "makes the filter form go away" do
      expect(page).to have_content("Build status")
      click_on "Hide filters"
      expect(page).not_to have_content("Build status")
    end

    it "hides the 'hide' link" do
      expect(page).to have_content("Hide filters")
      click_on "Hide filters"
      expect(page).not_to have_content("Hide filters")
    end

    it "shows the 'show' link" do
      expect(page).not_to have_content("Filters")
      click_on "Hide filters"
      expect(page).to have_content("Filters")
    end
  end

  describe "Showing filters" do
    it "shows the filter form" do
      expect(page).not_to have_content("Build status")
      click_on "Filters"
      expect(page).to have_content("Build status")
    end

    it "hides the 'show' link" do
      expect(page).to have_content("Filters")
      click_on "Filters"
      expect(page).not_to have_content("Filters")
    end

    it "shows the 'hide' link" do
      expect(page).not_to have_content("Hide filters")
      click_on "Filters"
      expect(page).to have_content("Hide filters")
    end
  end
end
