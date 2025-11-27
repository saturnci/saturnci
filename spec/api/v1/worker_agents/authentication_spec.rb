require "rails_helper"

describe "Test Runner Agents Authentication", type: :request do
  describe "GET /api/v1/test_runner_agents/test_runners/:test_runner_id/test_runner_assignments" do
    let!(:test_runner_assignment) { create(:test_runner_assignment) }
    let!(:test_runner) { test_runner_assignment.worker }

    context "with valid test runner credentials" do
      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
          test_runner.id,
          test_runner.access_token.value
        )

        get(
          api_v1_test_runner_agents_test_runner_test_runner_assignments_path(
            test_runner_id: test_runner.id,
            format: :json
          ),
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end
    end
  end
end
