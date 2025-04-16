require "rails_helper"

describe "Change start builds automatically on Git push", type: :system do
  let!(:repository) { create(:repository) }

  before do
    login_as(repository.user)
    visit repository_settings_general_settings_path(repository)
  end

  context "from yes to no" do
    it "gets saved to no" do
      choose "No"
      click_on "Save"

      # To prevent race condition
      expect(page).to have_content("Settings saved")

      expect(page).to have_checked_field("repository_start_builds_automatically_on_git_push_false")
    end
  end
end
