require "rails_helper"

describe "Cancel build", type: :system do
  let!(:run) { create(:run) }

  before do
    stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{run.runner_id}").to_return(status: 200)
    user = create(:user)
    login_as(user, scope: :user)
  end

  it "sets the status to 'Cancelled'" do
    visit run_path(run, "test_output")

    click_on "Cancel"
    expect(page).to have_content("Cancelled")
  end
end
