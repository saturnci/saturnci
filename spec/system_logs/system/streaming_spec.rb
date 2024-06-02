require "rails_helper"

describe "Streaming", type: :system do
  let!(:job) { create(:job) }

  before do
    login_as(job.build.project.user, scope: :user)
  end

  it "streams" do
    visit job_detail_content_project_build_job_path(
      job.build.project,
      job.build,
      job,
      "system_logs"
    )

    # somehow cause the job's system logs to get updated
    # assert that we see the updated contents on the page (without refreshing)
  end
end
