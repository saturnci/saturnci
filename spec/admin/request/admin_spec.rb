require "rails_helper"

describe "Admin", type: :request do
  context "super admin" do
    let!(:super_admin_user) { create(:user, super_admin: true) }

    before do
      login_as(super_admin_user, scope: :user)
    end

    describe "GET /admin" do
      it "returns a 200 response" do
        get admin_root_path
        expect(response).to have_http_status(200)
      end
    end
  end

  context "non-super admin" do
    let!(:non_super_admin_user) { create(:user) }

    before do
      login_as(non_super_admin_user, scope: :user)
    end

    describe "GET /admin" do
      it "returns a 401 response" do
        get admin_root_path
        expect(response).to have_http_status(401)
      end

      it "does not render the page" do
        get admin_root_path
        expect(response.body).to be_empty
      end
    end
  end
end
