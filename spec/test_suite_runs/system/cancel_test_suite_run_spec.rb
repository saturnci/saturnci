require "rails_helper"

describe "Cancel test suite run", type: :system do
  let!(:run) { create(:run, :with_test_runner) }

  before do
    stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.test_runner.cloud_id}").to_return(status: 200)

    allow_any_instance_of(User).to receive(:can_hit_github_api?).and_return(true)
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(run.test_suite_run.repository.user)
  end

  it "sets the status to 'Cancelled'" do
    visit run_path(run, "test_output")

    click_on "Cancel"
    expect(page).to have_content("Cancelled")
  end
end
