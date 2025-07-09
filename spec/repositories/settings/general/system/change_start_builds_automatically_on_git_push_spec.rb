require "rails_helper"

describe "Change start test suite runs automatically on Git push", type: :system do
  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:github_repositories).and_return([repository])
    login_as(repository.user)
    visit repository_settings_general_settings_path(repository)
  end

  context "from unchecked to checked" do
    it "gets saved to checked" do
      check "Start test suite runs automatically on git push"
      click_on "Save"

      # To prevent race condition
      expect(page).to have_content("Settings saved")

      expect(page).to have_checked_field("Start test suite runs automatically on git push")
    end
  end

  context "from checked to unchecked" do
    before do
      repository.update!(start_builds_automatically_on_git_push: true)
      visit repository_settings_general_settings_path(repository)
    end

    it "gets saved to unchecked" do
      uncheck "Start test suite runs automatically on git push"
      click_on "Save"

      # To prevent race condition
      expect(page).to have_content("Settings saved")

      expect(page).to have_unchecked_field("Start test suite runs automatically on git push")
    end
  end
end
