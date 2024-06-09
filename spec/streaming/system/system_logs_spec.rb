require "rails_helper"
require "net/http"

describe "System log streaming", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:job) do
    create(:job, system_logs: "original system log content")
  end

  before do
    login_as(job.build.project.user, scope: :user)
    visit job_path(job, "system_logs")
  end

  context "before log update occurs" do
    it "shows the original content" do
      expect(page).to have_content("original system log content")
    end
  end

  context "staying on system log tab" do
    context "after log update occurs" do
      before do
        http_request(
          api_authorization_headers: api_authorization_headers,
          path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
          body: "new system log content"
        )
      end

      it "shows the new content" do
        expect(page).to have_content("new system log content")
      end

      it "does not show the old content" do
        expect(page).to have_content("original system log content", count: 1)
      end
    end
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
