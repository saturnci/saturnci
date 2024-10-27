require "rails_helper"

describe "Cancel build", type: :system do
  let!(:job) { create(:job) }

  before do
    stub_request(:delete, "https://api.digitalocean.com/v2/droplets/#{job.job_machine_id}").to_return(status: 200)
    user = create(:user)
    login_as(user, scope: :user)
  end

  it "sets the status to 'Cancelled'" do
    visit project_build_path(job.build.project, job.build)

    click_on "Cancel"
    expect(page).to have_content("Cancelled")
  end
end
