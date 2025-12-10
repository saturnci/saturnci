require "rails_helper"

describe "Test output", type: :system do
  let!(:task) { create(:task, test_output: "this is the test output") }

  before do
    login_as(task.test_suite_run.repository.user)
  end

  it "is the default" do
    visit run_path(task, "test_output")
    expect(page).to have_content("this is the test output")
  end
end
