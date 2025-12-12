require "rails_helper"

describe "Worker Agents Authentication", type: :request do
  describe "POST /api/v1/worker_agents/workers/:worker_id/worker_events" do
    let!(:worker) { create(:worker) }

    context "with valid worker credentials" do
      it "returns success" do
        credentials = ActionController::HttpAuthentication::Basic.encode_credentials(
          worker.id,
          worker.access_token.value
        )

        post(
          api_v1_worker_agents_worker_worker_events_path(
            worker_id: worker.id,
            format: :json
          ),
          params: { type: "test_event" },
          headers: { "Authorization" => credentials }
        )

        expect(response).to have_http_status(:success)
      end
    end
  end
end
