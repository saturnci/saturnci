require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "run events", type: :request do
  describe "POST /api/v1/test_runner_agents/runs/:id/run_events" do
    let!(:run) { create(:run, :with_test_runner) }
    let!(:test_runner) { run.test_runner }

    it "increases the count of run events by 1" do
      expect {
        post(
          api_v1_test_runner_agents_run_run_events_path(run),
          params: { type: "runner_ready" },
          headers: test_runner_agents_api_authorization_headers(test_runner)
        )
      }.to change(RunEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_test_runner_agents_run_run_events_path(run),
        params: { type: "runner_ready" },
        headers: test_runner_agents_api_authorization_headers(test_runner)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end
  end
end
