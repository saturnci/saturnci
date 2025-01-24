require "rails_helper"

describe "Sign up with Github", type: :system do
  context "success" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
        provider: "github",
        uid: "123545",
        info: {
          email: "test@example.com",
          name: "John Smith"
        },
        credentials: {
          token: "mock_token_123"
        }
      )
    end

    it "redirects to GitHub accounts page" do
      visit new_user_registration_path
      click_on "Sign up with GitHub"
      
      expect(page).to have_content("GitHub Accounts")
    end
  end
end
