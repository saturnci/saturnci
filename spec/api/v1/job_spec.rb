require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "job", type: :request do
  let!(:job) { create(:job) }

  before do
    allow(job).to receive(:ip_address).and_return("225.218.120.138")
    allow(Job).to receive(:find).and_return(job)
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
