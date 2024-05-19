require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test output", type: :request do
  let!(:job) { create(:job) }

  describe "POST /api/v1/jobs/:id/test_output" do
    it "adds test output to a job" do
      post(
        api_v1_job_test_output_path(job_id: job.id),
        params: "test output content",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(job.reload.test_output).to eq("test output content")
    end
  end

  describe "appending" do
    it "appends anything new to the end of the test output rather than replacing the log content entirely" do
      post(
        api_v1_job_test_output_path(job_id: job.id),
        params: "first chunk ",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      post(
        api_v1_job_test_output_path(job_id: job.id),
        params: "second chunk",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(job.reload.test_output).to eq("first chunk second chunk")
    end
  end
end
