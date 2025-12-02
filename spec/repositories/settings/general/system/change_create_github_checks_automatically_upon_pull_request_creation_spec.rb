require "rails_helper"

describe "Change create GitHub checks automatically upon pull request creation", type: :system do
  let!(:repository) { create(:repository) }

  before do
    allow_any_instance_of(User).to receive(:github_repositories).and_return([repository])
    login_as(repository.user)
    visit repository_settings_general_settings_path(repository)
  end

  context "from unchecked to checked" do
    it "gets saved to checked" do
      check "Create GitHub checks automatically upon pull request creation"
      click_on "Save"

      expect(page).to have_content("Settings saved")

      expect(page).to have_checked_field("Create GitHub checks automatically upon pull request creation")
    end
  end

  context "from checked to unchecked" do
    before do
      repository.update!(create_github_checks_automatically_upon_pull_request_creation: true)
      visit repository_settings_general_settings_path(repository)
    end

    it "gets saved to unchecked" do
      uncheck "Create GitHub checks automatically upon pull request creation"
      click_on "Save"

      expect(page).to have_content("Settings saved")

      expect(page).to have_unchecked_field("Create GitHub checks automatically upon pull request creation")
    end
  end
end
