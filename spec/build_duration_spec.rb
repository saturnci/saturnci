require "rails_helper"

describe "Duration", type: :system do
  it "displays the build duration" do
    job = create(:job, test_report: "passed")

    create(
      :job_event,
      type: :test_suite_finished,
      job: job,
      created_at: job.created_at + ((5 * 60) + 10).seconds
    )

    user = create(:user)
    login_as(user, scope: :user)
    visit project_path(job.build.project)

    expect(page).to have_content("5m 10s")
  end
end
