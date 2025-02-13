require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "Complete syslogs", type: :request do
  let!(:run) { create(:run) }

  describe "POST /api/v1/runs/:id/complete_syslogs" do
    it "adds json output to a run" do
      post(
        api_v1_run_complete_syslogs_path(run_id: run.id),
        params: "stuff happened",
        headers: api_authorization_headers(run.build.project.user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.complete_syslog).to eq("stuff happened")
    end
  end
end

