require "rails_helper"
require "octokit"

describe "Infinite redirect prevention", type: :request do
  describe "when user has expired GitHub token" do
    let(:user) { create(:user) }

    before do
      # Create a user with an expired/invalid token
      GitHubOAuthToken.create!(user: user, value: "expired_token_123")
      
      # Stub GitHub API to return 401 for this token
      stub_request(:get, "https://api.github.com/user")
        .with(headers: {'Authorization' => 'token expired_token_123'})
        .to_return(status: 401)
    end

    it "does not create infinite redirect loop" do
      login_as user
      Rails.cache.clear
      
      redirect_count = 0
      max_redirects = 5
      
      # Start by visiting sign-in page  
      get new_user_session_path
      
      # Follow redirects and count them
      while response.status == 302 && redirect_count < max_redirects
        redirect_count += 1
        follow_redirect!
        
        # If we hit max redirects, we're in an infinite loop
        if redirect_count >= max_redirects
          fail "Infinite redirect detected! Followed #{max_redirects} redirects between sign-in and root pages"
        end
      end
      
      # With the fix: should eventually reach the sign-in page (user gets signed out)
      # Without the fix: would hit max redirects due to infinite loop
      expect(response).to have_http_status(200)
      expect(response.body).to include("Sign in")
      expect(redirect_count).to be < max_redirects
    end
    
    context "demonstrating the infinite redirect scenario" do
      it "shows how infinite redirect occurs when GitHub API check runs on devise controllers" do
        login_as user
        Rails.cache.clear
        
        # Mock sign_out to simulate browser scenario where sign_out doesn't take immediate effect
        allow_any_instance_of(ApplicationController).to receive(:sign_out)
        
        # This test demonstrates what would happen without the fix:
        # The GitHub API check would run on the sign-in page, causing infinite redirects
        expect {
          redirect_count = 0
          max_redirects = 3
          
          get new_user_session_path
          
          while response.status == 302 && redirect_count < max_redirects
            redirect_count += 1
            follow_redirect!
          end
          
          if redirect_count >= max_redirects
            raise "Infinite redirect would occur without the fix"
          end
        }.to raise_error("Infinite redirect would occur without the fix")
      end
    end
  end
end
