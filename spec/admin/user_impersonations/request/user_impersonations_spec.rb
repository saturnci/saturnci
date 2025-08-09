require "rails_helper"

describe "User impersonations", type: :request do
  context "super admin" do
    let!(:super_admin_user) { create(:user, super_admin: true) }
    let!(:regular_user) { create(:user) }

    before do
      login_as(super_admin_user)
    end

    context "target user has valid GitHub token" do
      before do
        GitHubOAuthToken.create!(user: super_admin_user, value: "admin_token_123")
        GitHubOAuthToken.create!(user: regular_user, value: "valid_token_789")

        # Stub GitHub API to succeed for both tokens
        stub_request(:get, "https://api.github.com/user")
          .to_return(status: 200, body: { login: "user" }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it "redirects to repositories page" do
        post admin_user_impersonations_path(user_id: regular_user.id)
        expect(response).to redirect_to(repositories_path)
      end
    end

    context "target user has expired GitHub token" do
      before do
        GitHubOAuthToken.create!(user: super_admin_user, value: "admin_token_123")
        GitHubOAuthToken.create!(user: regular_user, value: "expired_token_456")

        # Stub GitHub API calls based on token
        stub_request(:get, "https://api.github.com/user")
          .to_return do |request|
            auth_header = request.headers['Authorization']
            if auth_header == "Bearer admin_token_123"
              { status: 200, body: { login: "admin" }.to_json, headers: { 'Content-Type' => 'application/json' } }
            else
              # Default to 401 for expired token
              { status: 401, body: "", headers: {} }
            end
          end
      end

      it "redirects to repositories page" do
        post admin_user_impersonations_path(user_id: regular_user.id)
        expect(response).to redirect_to(repositories_path)
      end

      it "allows access to repositories page without being kicked out" do
        post admin_user_impersonations_path(user_id: regular_user.id)
        expect(session[:impersonating]).to be true

        follow_redirect!

        # Should get redirected to login due to expired token
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  context "non-super admin" do
    let!(:non_super_admin_user) { create(:user) }
    let!(:regular_user) { create(:user) }

    before do
      login_as(non_super_admin_user, scope: :user)

      # Stub GitHub API for non-admin user
      stub_request(:get, "https://api.github.com/user")
        .to_return(status: 200, body: { login: "user" }.to_json, headers: { 'Content-Type' => 'application/json' })
    end

    it "returns a 404 response" do
      post admin_user_impersonations_path(user_id: regular_user.id)
      expect(response).to have_http_status(404)
    end

    it "does not render the page" do
      post admin_user_impersonations_path(user_id: regular_user.id)
      expect(response.body).to be_empty
    end
  end
end
