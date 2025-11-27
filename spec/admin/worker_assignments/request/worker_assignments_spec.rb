require "rails_helper"

describe "Test Runner Assignments", type: :request do
  context "super admin" do
    let!(:super_admin_user) { create(:user, super_admin: true) }

    before do
      login_as(super_admin_user, scope: :user)
    end

    describe "GET /admin/test_runner_assignments" do
      it "returns a 200 response" do
        get admin_test_runner_assignments_path
        expect(response).to have_http_status(200)
      end
    end
  end

  context "non-super admin" do
    let!(:non_super_admin_user) { create(:user) }

    before do
      login_as(non_super_admin_user, scope: :user)
    end

    describe "GET /admin/test_runner_assignments" do
      it "returns a 404 response" do
        get admin_test_runner_assignments_path
        expect(response).to have_http_status(404)
      end

      it "does not render the page" do
        get admin_test_runner_assignments_path
        expect(response.body).to be_empty
      end
    end
  end
end
