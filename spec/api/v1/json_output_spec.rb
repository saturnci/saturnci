require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "JSON output", type: :request do
  let!(:run) { create(:run) }
  let!(:user) { run.build.project.user }

  describe "POST /api/v1/runs/:id/json_output" do
    it "adds json output to a run" do
      post(
        api_v1_run_json_output_path(run_id: run.id),
        params: Base64.encode64("JSON output content"),
        headers: api_authorization_headers(user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.json_output).to eq("JSON output content")
    end
  end
end
