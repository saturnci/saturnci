require "rails_helper"

describe "Add secrets", type: :system do
  let!(:project) { create(:project) }

  before do
    login_as(project.user, scope: :user)
  end

  it "adds a secret" do
    visit project_project_secret_collection_path(project)

    fill_in "project_secrets_0_key", with: "DATABASE_USERNAME"
    fill_in "project_secrets_0_value", with: "steve"
    click_on "Save"

    expect(page).to have_content("Secrets")
    expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")
  end

  context "secret already exists" do
    it "does not error" do
      visit project_project_secret_collection_path(project)

      fill_in "project_secrets_0_key", with: "DATABASE_USERNAME"
      fill_in "project_secrets_0_value", with: "steve"
      click_on "Save"

      expect(page).to have_content("Secrets")
      expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")

      click_on "Save"
      expect(page).to have_content("Secrets")
      expect(page).to have_field("project_secrets_0_key", with: "DATABASE_USERNAME")
    end
  end
end
