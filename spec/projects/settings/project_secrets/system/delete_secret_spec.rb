require "rails_helper"

describe "Delete secret", type: :system do
  let!(:repository) { create(:repository) }

  before do
    login_as(repository.user)
  end

  context "secret FOO exists" do
    before do
      create(:project_secret, key: "FOO", value: "BAR", repository:)
      create(:project_secret, key: "BAR", value: "BAR", repository:)
    end

    it "deletes the target secret" do
      visit repository_settings_project_secret_collection_path(repository)
      find_field("project_secrets_0_key", with: "FOO").set("")
      click_on "Save"

      sleep(1) # to prevent race condition
      expect(page).not_to have_field("project_secrets_0_key", with: "FOO")
    end

    it "does not delete other secrets" do
      visit repository_settings_project_secret_collection_path(repository)
      find_field("project_secrets_0_key", with: "FOO").set("")
      click_on "Save"

      sleep(1) # to prevent race condition
      expect(page).to have_field("project_secrets_0_key", with: "BAR")
    end
  end
end
