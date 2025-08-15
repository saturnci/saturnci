require 'rails_helper'
require 'octokit'

RSpec.describe "GitHub token expiration", type: :request do
  context "when user has expired GitHub token" do
    let(:user) { create(:user) }
    let(:octokit_client) { instance_double(Octokit::Client) }
    
    before do
      Rails.cache.clear
      allow(Octokit::Client).to receive(:new).and_return(octokit_client)
      allow(octokit_client).to receive(:user).and_raise(Octokit::Unauthorized)
      allow(octokit_client).to receive(:repositories).and_raise(Octokit::Unauthorized)
    end

    it "does not create redirect loop when accessing sign-in page after being signed out" do
      # First, login and access a page that triggers the GitHub API check
      login_as user
      get repositories_path
      expect(response).to redirect_to(new_user_session_path)
      
      # Follow the redirect to sign-in page
      follow_redirect!
      expect(response).to have_http_status(200)
      expect(response.body).to include("Sign in")
      
      # Ensure we're not in a redirect loop
      expect(response).not_to be_redirect
    end

    it "allows access to sign-in page without GitHub API check" do
      # Access sign-in page directly without being logged in
      get new_user_session_path
      expect(response).to have_http_status(200)
      expect(response.body).to include("Sign in")
    end
  end
end