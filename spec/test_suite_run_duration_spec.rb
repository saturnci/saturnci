require "rails_helper"

describe "Test suite run duration", type: :system do
  it "displays the test suite run duration" do
    run = create(:run, :passed)

    create(
      :run_event,
      type: :run_finished,
      run: run,
      created_at: run.created_at + ((5 * 60) + 10).seconds
    )

    login_as(run.test_suite_run.project.user, scope: :user)
    visit project_path(run.test_suite_run.project)

    expect(page).to have_content("5m 10s")
  end
end
