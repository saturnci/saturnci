require 'rails_helper'

RSpec.describe "Sessions", type: :request do
  describe "GET /users/sign_in" do
    context "when user is signed in with expired GitHub token" do
      let(:user) { create(:user) }
      let(:octokit_client) { instance_double(Octokit::Client) }
      
      before do
        login_as user
        Rails.cache.clear
        allow(Octokit::Client).to receive(:new).and_return(octokit_client)
        allow(octokit_client).to receive(:user).and_raise(Octokit::Unauthorized)
      end

      it "redirects to root path (not infinite loop)" do
        get new_user_session_path
        expect(response).to redirect_to(root_path)
      end
    end

    context "when user is not signed in" do
      it "shows the sign in page" do
        get new_user_session_path
        expect(response).to have_http_status(200)
      end
    end
  end
end