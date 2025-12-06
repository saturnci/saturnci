require "rails_helper"

describe "POST /api/v1/test_suite_reruns", type: :request do
  let!(:user) { create(:user, super_admin: true) }
  let!(:personal_access_token) { create(:personal_access_token, user:) }
  let!(:test_suite_run) { create(:build) }

  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(
      user.id.to_s,
      personal_access_token.access_token.value
    )
  end

  describe "with valid params" do
    it "creates a new test suite run" do
      expect {
        post(
          api_v1_test_suite_reruns_path(test_suite_run_id: test_suite_run.id),
          headers: { "Authorization" => credentials }
        )
      }.to change(TestSuiteRun, :count).by(1)
    end

    it "returns the new test suite run id" do
      post(
        api_v1_test_suite_reruns_path(test_suite_run_id: test_suite_run.id),
        headers: { "Authorization" => credentials }
      )

      expect(response).to have_http_status(:success)

      returned_id = JSON.parse(response.body)["id"]
      expect(returned_id).not_to eq(test_suite_run.id)
    end
  end
end
