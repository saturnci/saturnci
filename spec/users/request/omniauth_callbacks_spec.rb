require "rails_helper"

describe "OmniauthCallbacks", type: :request do
  describe "GET /users/auth/github/callback" do
    before do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
        provider: "github",
        uid: "123456",
        info: {
          email: "user@example.com",
          name: "Test User"
        },
        credentials: {
          token: "mock_token"
        }
      })

      # Set up the request environment for OmniAuth
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:github]
    end

    let!(:user) { create(:user, provider: "github", uid: "123456") }

    it "signs in and redirects the user" do
      get "/users/auth/github/callback"
      expect(response).to be_redirect
      expect(session[:github_oauth_token]).to eq("mock_token")
    end
  end
end
