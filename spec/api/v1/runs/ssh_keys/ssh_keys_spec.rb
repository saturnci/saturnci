require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "SSH keys", type: :request do
  let!(:job) { create(:job) }

  describe "GET /api/v1/job/:id/ssh_key" do
    it "returns a 200 response" do
      get(
        api_v1_job_ssh_key_path(job_id: job.id),
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
    end
  end
end
