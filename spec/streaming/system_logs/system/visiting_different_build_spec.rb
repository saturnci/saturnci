require "rails_helper"

describe "Visiting different build", type: :system do
  include APIAuthenticationHelper
  include SaturnAPIHelper
  include NavigationHelper

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
        visit_build_tab("system_logs", job: original_job)
        navigate_to_build(other_job.build)
        navigate_to_build_tab("system_logs", job: other_job)
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
