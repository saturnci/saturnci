require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "run finished events", type: :request do
  describe "POST /api/v1/jobs/:id/run_finished_events" do
    let!(:run) { create(:run) }

    it "increases the count of run events by 1" do
      expect {
        post(
          api_v1_job_run_finished_events_path(run),
          headers: api_authorization_headers
        )
      }.to change(RunEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_job_run_finished_events_path(run),
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end

    it "creates a charge for the run" do
      expect {
        post(
          api_v1_job_run_finished_events_path(run),
          headers: api_authorization_headers
        )
      }.to change { run.reload.charge.present? }.from(false).to(true)
    end
  end
end
