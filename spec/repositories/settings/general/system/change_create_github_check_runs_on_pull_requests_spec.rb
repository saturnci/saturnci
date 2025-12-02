require "rails_helper"

describe "Change create GitHub check runs on pull requests", type: :system do
  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:github_repositories).and_return([repository])
    login_as(repository.user)
    visit repository_settings_general_settings_path(repository)
  end

  context "from unchecked to checked" do
    it "gets saved to checked" do
      check "Create GitHub check runs on pull requests"
      click_on "Save"

      expect(page).to have_content("Settings saved")

      expect(page).to have_checked_field("Create GitHub check runs on pull requests")
    end
  end

  context "from checked to unchecked" do
    before do
      repository.update!(create_github_check_runs_on_pull_requests: true)
      visit repository_settings_general_settings_path(repository)
    end

    it "gets saved to unchecked" do
      uncheck "Create GitHub check runs on pull requests"
      click_on "Save"

      expect(page).to have_content("Settings saved")

      expect(page).to have_unchecked_field("Create GitHub check runs on pull requests")
    end
  end
end
