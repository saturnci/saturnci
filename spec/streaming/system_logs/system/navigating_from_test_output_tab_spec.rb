require "rails_helper"

describe "Navigating from test output tab", type: :system do
  include SaturnAPIHelper
  include NavigationHelper

  let!(:job) { create(:job) }

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "test_output")
  end

  context "navigating to the system logs tab" do
    before do
      navigate_to_build_tab("system_logs", job:)

      http_request(
        api_authorization_headers: api_authorization_headers,
        path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
        body: "new system log content"
      )
    end

    it "shows the new content" do
      expect(page).to have_content("new system log content")
    end
  end
end
