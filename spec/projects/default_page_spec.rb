require "rails_helper"

describe "Default page", type: :system do
  context "signed in" do
    let!(:user) { create(:user) }

    before do
      login_as(user, scope: :user)
    end

    it "shows the GitHub Accounts page" do
      visit root_path
      expect(page).to have_content("GitHub Accounts")
    end
  end

  context "not signed in" do
    it "shows the sign-in page" do
      visit root_path
      expect(page).to have_content("Sign in")
    end
  end
end
