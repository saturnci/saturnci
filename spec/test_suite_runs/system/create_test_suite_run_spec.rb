require "rails_helper"

describe "Start test suite run", type: :system do
  let!(:test_suite_run) { create(:build) }

  before do
    login_as(test_suite_run.project.user)

    allow_any_instance_of(Run).to receive(:start!)
  end

  it "starts the test suite run" do
    visit project_build_path(id: test_suite_run.id, project_id: test_suite_run.project.id)
    expect(page).to have_content("Not Started")

    click_on "Start"
    expect(page).to have_content("Running")
  end
end
