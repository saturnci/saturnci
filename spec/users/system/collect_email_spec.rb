require "rails_helper"

describe "Collecting email", type: :system do
  context "user has an email address" do
    let!(:user) { create(:user) }

    before { login_as(user) }

    it "allows the Repositories page to be shown" do
      visit repositories_path
      expect(page).to have_content("Repositories")
    end
  end

  context "user does not have an email address" do
    let!(:user) { create(:user, email: nil) }

    before do
      login_as(user)
      visit repositories_path
    end

    it "prompts the user for an email address" do
      fill_in "Email", with: "test@example.com"
      click_on "Continue"
      expect(page).to have_content("Repositories")
    end

    context "invalid email address" do
      it "shows a validation error" do
        fill_in "Email", with: "blah"
        click_on "Continue"
        expect(page).to have_content("Email is invalid")
      end
    end
  end
end
