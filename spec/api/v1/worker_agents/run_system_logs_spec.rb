require "rails_helper"
include APIAuthenticationHelper

describe "system logs", type: :request do
  let!(:run) { create(:run, :with_test_runner) }
  let!(:test_runner) { run.test_runner }

  describe "POST /api/v1/worker_agents/runs/:id/system_logs" do
    it "adds system logs to a run" do
      post(
        api_v1_worker_agents_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("system log content"),
        headers: worker_agents_api_authorization_headers(test_runner).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("system log content")
      expect(response.status).to eq(200)
    end
  end

  describe "appending" do
    it "appends anything new to the end of the logs rather than replacing the log content entirely" do
      post(
        api_v1_worker_agents_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("first chunk "),
        headers: worker_agents_api_authorization_headers(test_runner).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_worker_agents_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("second chunk"),
        headers: worker_agents_api_authorization_headers(test_runner).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("first chunk second chunk")
      expect(run.runner_system_log.reload.content).to eq("first chunk second chunk")
    end
  end
end
