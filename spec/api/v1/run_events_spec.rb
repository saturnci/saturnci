require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "job events", type: :request do
  describe "POST /api/v1/jobs/:id/job_events" do
    let!(:job) { create(:job) }

    it "increases the count of job events by 1" do
      expect {
        post(
          api_v1_job_job_events_path(job), 
          params: { type: "job_machine_ready" },
          headers: api_authorization_headers
        )
      }.to change(JobEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_job_job_events_path(job),
        params: { type: "job_machine_ready" },
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end
  end
end
