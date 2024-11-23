require "rails_helper"

describe "Show new build", type: :system do
  let!(:build) { create(:build) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  it "shows a link to the new build" do
    visit project_path(build.project)
    create(:build, project: build.project)
    expect(page).to have_content("1 new build")
  end
end
