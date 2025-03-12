require "rails_helper"
include APIAuthenticationHelper

describe "Test runner events", type: :request do
  describe "POST /api/v1/test_runner_events" do
    let!(:user) { create(:user, super_admin: true) }
    let!(:test_runner) { create(:test_runner) }

    it "creates a test runner event" do
      expect {
        post(
          api_v1_test_runner_test_runner_events_path(test_runner_id: test_runner.id),
          params: {
            type: "ready_signal_received",
          },
          headers: api_authorization_headers(user)
        )
      }.to change { TestRunnerEvent.count }.by(1)
    end

    it "returns 201" do
      post(
        api_v1_test_runner_test_runner_events_path(test_runner_id: test_runner.id),
        params: {
          type: "ready_signal_received",
        },
        headers: api_authorization_headers(user)
      )

      expect(response).to have_http_status(:created)
    end
  end
end
