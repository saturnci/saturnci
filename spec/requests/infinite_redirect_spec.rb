require 'rails_helper'
require 'octokit'

RSpec.describe "Infinite redirect prevention", type: :request do
  describe "when user has expired GitHub token" do
    let(:user) { create(:user) }
    let(:octokit_client) { instance_double(Octokit::Client) }
    
    before do
      Rails.cache.clear
      allow(Octokit::Client).to receive(:new).and_return(octokit_client)
      allow(octokit_client).to receive(:user).and_raise(Octokit::Unauthorized)
    end

    it "does not create infinite redirect when accessing devise pages" do
      login_as user
      
      # This should not cause infinite redirect
      get new_user_session_path
      
      # Should redirect to root since user is already signed in
      expect(response).to redirect_to(root_path)
      
      # Follow redirect to ensure no loop
      follow_redirect!
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end