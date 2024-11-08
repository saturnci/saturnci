require "rails_helper"

describe "Delete secret", type: :system do
  let!(:project) { create(:project) }

  before do
    login_as(project.user, scope: :user)
  end

  context "secret FOO exists" do
    before do
      create(:project_secret, key: "FOO", value: "BAR", project:)
      create(:project_secret, key: "BAR", value: "BAR", project:)
    end

    it "deletes the target secret" do
      visit project_project_secret_collection_path(project)
      find_field("project_secrets_0_key", with: "FOO").set("")
      click_on "Save"

      sleep(1) # to prevent race condition
      expect(page).not_to have_field("project_secrets_0_key", with: "FOO")
    end

    it "does not delete other secrets" do
      visit project_project_secret_collection_path(project)
      find_field("project_secrets_0_key", with: "FOO").set("")
      click_on "Save"

      sleep(1) # to prevent race condition
      expect(page).to have_field("project_secrets_0_key", with: "BAR")
    end
  end
end
