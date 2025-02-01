require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "system logs", type: :request do
  let!(:run) { create(:run) }

  describe "POST /api/v1/runs/:id/system_logs" do
    it "adds system logs to a run" do
      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("system log content"),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("system log content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the logs rather than replacing the log content entirely" do
      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("first chunk "),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("second chunk"),
        headers: api_authorization_headers(run.build).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("first chunk second chunk")
    end
  end
end
