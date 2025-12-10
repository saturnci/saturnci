require "rails_helper"

describe "Showing and hiding filters", type: :system do
  let!(:test_suite_run) { create(:test_suite_run) }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(test_suite_run.repository.user)
    visit repository_build_path(id: test_suite_run.id, repository_id: test_suite_run.repository.id)
  end

  describe "Hiding filters" do
    before { click_on "Filters" }

    it "makes the filter form go away" do
      expect(page).to have_content("Status")
      click_on "Hide filters"
      expect(page).not_to have_content("Status")
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
      expect(page).not_to have_content("Status")
      click_on "Filters"
      expect(page).to have_content("Status")
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
