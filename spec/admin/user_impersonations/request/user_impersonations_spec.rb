require "rails_helper"

describe "User impersonations", type: :request do
  let!(:super_admin_user) { create(:user, super_admin: true) }
  let!(:expired_token_user) { create(:user) }
  let!(:valid_token_user) { create(:user) }

  before do
    GitHubOAuthToken.create!(user: super_admin_user, value: "admin_token_123")
    GitHubOAuthToken.create!(user: expired_token_user, value: "expired_token_456") 
    GitHubOAuthToken.create!(user: valid_token_user, value: "valid_token_789")

    stub_request(:get, "https://api.github.com/user")
      .to_return do |request|
        auth_header = request.headers['Authorization']
        case auth_header
        when "token admin_token_123"
          { status: 200 }
        when "token valid_token_789"
          { status: 200 }
        when "token expired_token_456"
          { status: 401 }
        else
          { status: 401 }
        end
      end
  end

  context "super admin impersonating user with valid token" do
    before do
      login_as(super_admin_user)
    end

    it "redirects to repositories page" do
      post admin_user_impersonations_path(user_id: valid_token_user.id)
      expect(response).to redirect_to(repositories_path)
    end

    it "sets impersonating session flag" do
      post admin_user_impersonations_path(user_id: valid_token_user.id)
      expect(session[:impersonating]).to be true
    end

    context "GitHub token is invalid" do
      before do
        allow_any_instance_of(User).to receive(:can_hit_github_api?).and_return(false)
      end

      it "still works" do
        post admin_user_impersonations_path(user_id: target_user.id)
        expect(response).to redirect_to(repositories_path)
      end
    end
  end

  context "super admin impersonating user with expired token" do
    before do
      login_as(super_admin_user)
    end

    it "redirects to repositories page" do
      post admin_user_impersonations_path(user_id: expired_token_user.id)
      expect(response).to redirect_to(repositories_path)
    end

    it "sets impersonating session flag" do
      post admin_user_impersonations_path(user_id: expired_token_user.id)
      expect(session[:impersonating]).to be true
    end

    it "should succeed: allows access even with expired token" do
      post admin_user_impersonations_path(user_id: expired_token_user.id)
      expect(session[:impersonating]).to be true

      follow_redirect!

      expect(response).to have_http_status(200)
    end
  end

  context "non-super admin attempting impersonation" do
    let!(:non_admin_user) { create(:user) }

    before do
      GitHubOAuthToken.create!(user: non_admin_user, value: "non_admin_token_999")
      
      stub_request(:get, "https://api.github.com/user")
        .to_return(status: 200)
      
      login_as(non_admin_user)
    end

    it "returns a 404 response" do
      post admin_user_impersonations_path(user_id: valid_token_user.id)
      expect(response).to have_http_status(404)
    end

    it "does not render the page" do
      post admin_user_impersonations_path(user_id: valid_token_user.id)
      expect(response.body).to be_empty
    end
  end
end
