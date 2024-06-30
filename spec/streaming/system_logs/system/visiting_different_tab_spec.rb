require "rails_helper"

describe "Visiting different tab", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:job) do
    create(:job, system_logs: "original system log content")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "system_logs")
  end

  context "visiting a different tab" do
    context "after log update occurs" do
      before do
        visit job_path(job, "test_output")

        http_request(
          api_authorization_headers: api_authorization_headers,
          path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
          body: "new system log content"
        )
      end

      it "does not show the system log content" do
        expect(page).not_to have_content("new system log content")
      end
    end
  end
end
