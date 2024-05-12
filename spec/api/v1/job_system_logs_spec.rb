require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "system logs", type: :request do
  let!(:job) { create(:job) }

  describe "POST /api/v1/jobs/:id/system_logs" do
    it "adds system logs to a job" do
      post(
        api_v1_job_system_logs_path(job_id: job.id),
        params: "system log content",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(job.reload.system_logs).to eq("system log content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the logs rather than replacing the log content entirely" do
      post(
        api_v1_job_system_logs_path(job_id: job.id),
        params: "first chunk ",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_job_system_logs_path(job_id: job.id),
        params: "second chunk",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(job.reload.system_logs).to eq("first chunk second chunk")
    end
  end
end
