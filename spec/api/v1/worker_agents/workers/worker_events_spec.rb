require "rails_helper"
include APIAuthenticationHelper

describe "Worker events", type: :request do
  describe "POST /api/v1/worker_agents/workers/:worker_id/worker_events" do
    let!(:worker) { create(:worker) }

    it "creates a worker event" do
      expect {
        post(
          api_v1_worker_agents_worker_worker_events_path(worker_id: worker.id),
          params: { type: "ready_signal_received" },
          headers: worker_agents_api_authorization_headers(worker)
        )
      }.to change { WorkerEvent.count }.by(1)
    end

    it "returns 201" do
      post(
        api_v1_worker_agents_worker_worker_events_path(worker_id: worker.id),
        params: { type: "ready_signal_received" },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(:created)
    end
  end
end
