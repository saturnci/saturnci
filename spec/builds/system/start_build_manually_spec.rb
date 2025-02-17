require "rails_helper"

describe "Start build manually", type: :system do
  let!(:build) { create(:build) }

  before do
    fake_runner_request = double("RunnerRequest")
    allow_any_instance_of(Run).to receive(:runner_request).and_return(fake_runner_request)
    allow(fake_runner_request).to receive(:execute!)

    login_as(build.project.user)
    visit project_build_path(build.project, build)
  end

  it "starts the build" do
    expect(page).to have_content("Not Started")
    click_on "Start"
    expect(page).to have_content("Running")
  end
end
