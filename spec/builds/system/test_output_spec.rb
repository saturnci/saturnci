require "rails_helper"

describe "Test output", type: :system do
  let!(:run) { create(:run, test_output: "this is the test output") }

  before do
    login_as(run.build.project.user, scope: :user)
  end

  it "is the default" do
    visit run_path(run, "test_output")
    expect(page).to have_content("this is the test output")
  end
end
