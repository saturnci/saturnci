require "rails_helper"

describe "User impersonations", type: :request do
  context "super admin" do
    let!(:super_admin_user) { create(:user, super_admin: true) }
    let!(:target_user) { create(:user) }

    before do
      login_as(super_admin_user, scope: :user)
    end

    context "user has a project" do
      let!(:target_user_project) { create(:project, user: target_user) }

      it "redirects to the user's projects" do
        post admin_user_impersonations_path(user_id: target_user.id)
        expect(response).to redirect_to(target_user_project)
      end

      it "shows the target user's projects" do
        post admin_user_impersonations_path(user_id: target_user.id)
        get github_accounts_path
        expect(response.body).to include("Signed in as #{target_user.name}")
      end
    end

    context "user does not have a project" do
      it "redirects somewhere else" do
        post admin_user_impersonations_path(user_id: target_user.id)
        expect(response.code).to eq("302")
      end
    end
  end

  context "non-super admin" do
    let!(:non_super_admin_user) { create(:user) }
    let!(:target_user) { create(:user) }

    before do
      login_as(non_super_admin_user, scope: :user)
    end

    it "returns a 404 response" do
      post admin_user_impersonations_path(user_id: target_user.id)
      expect(response).to have_http_status(404)
    end

    it "does not render the page" do
      post admin_user_impersonations_path(user_id: target_user.id)
      expect(response.body).to be_empty
    end
  end
end
