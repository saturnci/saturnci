require "rails_helper"

describe "Visiting different build", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper

  let!(:original_job) do
    create(:job, system_logs: "original system log content")
  end

  before do
    login_as(original_job.build.project.user, scope: :user)
    visit job_path(original_job, "system_logs")
  end

  context "visiting a different build" do
    let!(:other_job) do
      create(:job, system_logs: "other job system logs") do |j|
        j.build.update!(
          project: original_job.build.project,
          commit_message: "Make other change."
        )
      end
    end

    context "after log update occurs" do
      before do
        visit_tab("system_logs", job: original_job)
        navigate_to_build(other_job.build)
        navigate_to_tab("system_logs", job: other_job)
        system_log_http_request(job: original_job, body: "new system log content")
      end

      it "does not show original job's system logs on the other job's system logs tab" do
        expect(page).not_to have_content(original_job.system_logs)
      end

      it "shows the other job's system logs on the other job's system logs tab" do
        expect(page).to have_content(other_job.system_logs)
      end
    end
  end
end

def visit_tab(tab_slug, job:)
  visit job_path(job, tab_slug)
  expect(page).to have_content(original_job.system_logs) # To prevent race condition
end

def navigate_to_build(build)
  # It's important that we visit the other job via Turbo,
  # not via a full page reload
  click_on "build_link_#{build.id}"
  expect(page).to have_content("Commit: #{other_job.build.commit_hash}") # to prevent race condition
end

def navigate_to_tab(tab_slug, job:)
  click_on "System Logs"
  expect(page).to have_content(other_job.system_logs) # to prevent race condition
end

def system_log_http_request(job:, body:)
  http_request(
    api_authorization_headers: api_authorization_headers,
    path: api_v1_job_system_logs_path(job_id: job.id, format: :json),
    body: "new system log content"
  )

  # Wait for request to finish
  sleep(0.5)
end
