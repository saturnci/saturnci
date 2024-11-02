require "rails_helper"

describe "User impersonations", type: :request do
  context "super admin" do
    let!(:super_admin_user) { create(:user, super_admin: true) }
    let!(:other_user) { create(:user) }
    let!(:other_user_project) { create(:project, user: other_user) }

    before do
      login_as(super_admin_user, scope: :user)
    end

    it "redirects to the user's projects" do
      post admin_user_impersonations_path(user_id: other_user.id)
      expect(response).to redirect_to(other_user_project)
    end
  end

  context "non-super admin" do
    let!(:non_super_admin_user) { create(:user) }
    let!(:other_user) { create(:user) }

    before do
      login_as(non_super_admin_user, scope: :user)
    end

    it "returns a 401 response" do
      post admin_user_impersonations_path(user_id: other_user.id)
      expect(response).to have_http_status(401)
    end

    it "does not render the page" do
      post admin_user_impersonations_path(user_id: other_user.id)
      expect(response.body).to be_empty
    end
  end
end
