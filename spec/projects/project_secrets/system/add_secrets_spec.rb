require "rails_helper"

describe "Add secrets", type: :system do
  let!(:project) { create(:project) }

  before do
    login_as(project.user, scope: :user)
  end

  it "adds a secret" do
    visit project_settings_project_secret_collection_path(project)

    fill_in "project_secrets_0_key", with: "DATABASE_USERNAME"
    fill_in "project_secrets_0_value", with: "steve"
    click_on "Save"

    expect(page).to have_content("Secrets")
    expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")
  end

  context "secret already exists" do
    before do
      visit project_settings_project_secret_collection_path(project)

      # This setup step is to make the secret already exist
      fill_in "project_secrets_0_key", with: "DATABASE_USERNAME"
      fill_in "project_secrets_0_value", with: "steve"
      click_on "Save"

      # To prevent race condition
      expect(page).to have_content("Secrets")
      expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")
    end

    it "does not error" do
      click_on "Save"
      expect(page).to have_content("Secrets")
      expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")
    end
  end
end
