require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "job machines", type: :request do
  describe "DELETE /api/v1/jobs/:id/job_machine" do
    let!(:job) { create(:job, job_machine_id: "123") }

    before do
      stub_request(
        :delete,
        "https://api.digitalocean.com/v2/droplets/123"
      ).to_return(status: 200, body: "", headers: {})           
    end

    it "returns an empty 200 response" do
      delete(
        api_v1_job_job_machine_path(job),
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end
  end
end
