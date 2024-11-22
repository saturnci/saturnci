require "rails_helper"

describe "Navigating from test output tab", type: :system do
  include SaturnAPIHelper
  include NavigationHelper

  let!(:run) { create(:run, system_logs: "stuff") }

  before do
    login_as(run.build.project.user, scope: :user)
    visit job_path(run, "test_output")
  end

  context "navigating to the system logs tab" do
    before do
      navigate_to_build_tab("system_logs", job: run)

      http_request(
        api_authorization_headers: api_authorization_headers,
        path: api_v1_run_system_logs_path(job_id: run.id, format: :json),
        body: Base64.encode64("new system log content")
      )
    end

    it "shows the new content" do
      expect(page).to have_content("new system log content")
    end
  end
end
