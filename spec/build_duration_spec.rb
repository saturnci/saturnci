require "rails_helper"

describe "Duration", type: :system do
  it "displays the build duration" do
    run = create(:run, :passed)

    create(
      :run_event,
      type: :run_finished,
      run: run,
      created_at: run.created_at + ((5 * 60) + 10).seconds
    )

    login_as(run.build.project.user, scope: :user)
    visit project_path(run.build.project)

    expect(page).to have_content("5m 10s")
  end
end
