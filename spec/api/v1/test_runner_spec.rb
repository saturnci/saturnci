require "rails_helper"
include APIAuthenticationHelper

describe "Test runners", type: :request do
  let!(:user) { create(:user, super_admin: true) }

  describe "GET /api/v1/test_runners" do
    let!(:test_runner) { create(:test_runner) }

    it "returns a list of test runners" do
      get(api_v1_test_runners_path, headers: api_authorization_headers(user))
      expect(response).to have_http_status(200)
    end
  end
end
