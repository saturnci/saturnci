require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "test reports", type: :request do
  describe "POST /api/v1/runs/:id/test_reports" do
    let!(:run) { create(:run) }

    it "adds a report to a run" do
      post(
        api_v1_run_test_reports_path(run_id: run.id),
        params: "test report content",
        headers: api_authorization_headers(run.build.project.user).merge({ "CONTENT_TYPE" => "text/plain" })
      )

      expect(run.reload.test_report).to eq("test report content")
    end
  end
end
