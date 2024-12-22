require "rails_helper"

describe "Change start builds automatically on Git push", type: :system do
  let!(:project) { create(:project) }

  before do
    login_as(project.user, scope: :user)
    visit project_settings_general_settings_path(project)
  end

  context "from yes to no" do
    it "gets saved to no" do
      choose "No"
      click_on "Save"

      # To prevent race condition
      expect(page).to have_content("Settings saved")

      expect(page).to have_checked_field("project_start_builds_automatically_on_git_push_false")
    end
  end
end
