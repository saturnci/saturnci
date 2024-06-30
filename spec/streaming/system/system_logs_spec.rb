require "rails_helper"

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
    context "after the first log update occurs" do
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

      context "after a second log update occurs" do
        before do
          http_request(
            api_authorization_headers: api_authorization_headers,
            path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
            body: "second system log update"
          )
        end

        it "shows the new content" do
          expect(page).to have_content("second system log update")
        end
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

  context "visiting a different build" do
    let!(:other_job) do
      create(:job, system_logs: "other job system logs") do |j|
        j.build.update!(
          project: job.build.project,
          commit_message: "Make other change."
        )
      end
    end

    context "after log update occurs" do
      before do
        visit job_path(job, "system_logs")
        expect(page).to have_content("original system log content") # To prevent race condition

        # It's important that we visit the other job via Turbo,
        # not via a full page reload
        click_on "build_link_#{other_job.build_id}"
        expect(page).to have_content("Make other change.", count: 2) # to prevent race condition

        click_on "System Logs"
        expect(page).to have_content("other job system logs") # to prevent race condition

        http_request(
          api_authorization_headers: api_authorization_headers,
          path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
          body: "new system log content"
        )

        # Wait for request to finish
        sleep(0.5)
      end

      it "does not show original job's system logs" do
        expect(page).to have_content("other job system logs")
      end
    end
  end
end
