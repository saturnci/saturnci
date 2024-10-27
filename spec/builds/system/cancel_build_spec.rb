require "rails_helper"

describe "Cancel build", type: :system do
  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  it "sets the status to 'Cancelled'" do
    build = create(:build, :with_job)
    visit project_build_path(build.project, build)

    click_on "Cancel"
    expect(page).to have_content("Cancelled")
  end
end
