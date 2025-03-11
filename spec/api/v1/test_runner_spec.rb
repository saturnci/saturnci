require "rails_helper"
include APIAuthenticationHelper

describe "Test runners", type: :request do
  let!(:user) { create(:user, super_admin: true) }
  let!(:test_runner) { create(:test_runner) }

  describe "GET /api/v1/test_runners" do
    it "returns a list of test runners" do
      get(api_v1_test_runners_path, headers: api_authorization_headers(user))
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/test_runners/:id" do
    before do
      allow_any_instance_of(RunnerNetwork).to receive(:ip_address).and_return("")
    end

    it "returns a 200 response" do
      get(
        api_v1_test_runner_path(test_runner.id),
        headers: api_authorization_headers(user)
      )
      expect(response).to have_http_status(200)
    end
  end
end
