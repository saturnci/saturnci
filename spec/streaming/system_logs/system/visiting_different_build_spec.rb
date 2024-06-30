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
