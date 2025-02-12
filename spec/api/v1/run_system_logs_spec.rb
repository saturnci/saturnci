require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "system logs", type: :request do
  let!(:run) { create(:run) }
  let!(:user) { run.build.project.user }

  describe "POST /api/v1/runs/:id/system_logs" do
    it "adds system logs to a run" do
      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("system log content"),
        headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("system log content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the logs rather than replacing the log content entirely" do
      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("first chunk "),
        headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        params: Base64.encode64("second chunk"),
        headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.system_logs).to eq("first chunk second chunk")
    end
  end

  context "raw error" do
    before do
      allow_any_instance_of(Run).to receive(:attributes).and_raise(StandardError.new("something went wrong"))

      post(
        api_v1_run_system_logs_path(run_id: run.id, format: :json),
        headers: api_authorization_headers(run.build.project.user)
      )
    end

    it "returns the error message" do
      expect(response.body["error"]).to be_present
    end

    it "returns a 400 status code" do
      expect(response.status).to eq(400)
    end
  end
end
