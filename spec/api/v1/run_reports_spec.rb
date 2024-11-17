require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test reports", type: :request do
  describe "POST /api/v1/jobs/:id/test_reports" do
    let!(:job) { create(:job) }

    it "adds a report to a job" do
      post(
        api_v1_job_test_reports_path(job_id: job.id),
        params: "test report content",
        headers: api_authorization_headers.merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(job.reload.test_report).to eq("test report content")
    end
  end
end
