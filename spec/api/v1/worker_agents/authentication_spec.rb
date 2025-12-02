require "rails_helper"

describe "Worker Agents Authentication", type: :request do
  describe "GET /api/v1/worker_agents/workers/:worker_id/worker_assignments" do
    let!(:worker_assignment) { create(:test_runner_assignment) }
    let!(:worker) { worker_assignment.worker }

    context "with valid worker credentials" do
      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
          worker.id,
          worker.access_token.value
        )

        get(
          api_v1_worker_agents_worker_worker_assignments_path(
            worker_id: worker.id,
            format: :json
          ),
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end
    end
  end
end
