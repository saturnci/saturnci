require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "job", type: :request do
  let!(:job) { create(:job) }

  before do
    allow_any_instance_of(JobMachineNetwork).to receive(:ip_address).and_return("")
  end

  describe "finding by abbreviated hash" do
    it "finds the job" do
      extend ApplicationHelper

      get(
        api_v1_job_path(abbreviated_hash(job.id)),
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/v1/job/:id" do
    it "returns a 200 response" do
      get(
        api_v1_job_path(job.id),
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
    end

    it "includes the id" do
      get(
        api_v1_job_path(job.id),
        headers: api_authorization_headers
      )
      response_body = JSON.parse(response.body)
      expect(response_body["id"]).to eq(job.id)
    end
  end
end
