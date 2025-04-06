require "rails_helper"

describe "Default page", type: :system do
  context "signed in" do
    let!(:user) { create(:user) }
    before { login_as(user) }

    it "shows the Repositories page" do
      visit root_path
      expect(page).to have_content("Repositories")
    end
  end

  context "not signed in" do
    it "shows the sign-in page" do
      visit root_path
      expect(page).to have_content("Sign in")
    end
  end
end
