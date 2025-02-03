require "rails_helper"
include APIAuthenticationHelper

describe "update run", type: :request do
  let!(:run) { create(:run) }

  describe "PATCH /api/v1/runs/:id" do
    it "changes terminate_on_completion from true to false" do
      patch(
        api_v1_run_path(run),
        params: { terminate_on_completion: false },
        headers: api_authorization_headers(run.build.project.user)
      )

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)["terminate_on_completion"]).to eq(false)
    end
  end
end
