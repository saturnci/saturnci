require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "runners", type: :request do
  describe "DELETE /api/v1/runs/:id/runner" do
    let!(:run) { create(:run, runner_id: "123") }

    before do
      stub_request(
        :delete,
        "https://api.digitalocean.com/v2/droplets/123"
      ).to_return(status: 200, body: "", headers: {})           
    end

    it "returns an empty 200 response" do
      delete(
        api_v1_run_runner_path(run),
        headers: api_authorization_headers(run.build.project.user)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end
  end
end
