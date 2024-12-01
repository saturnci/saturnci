require "rails_helper"

describe "Show new build", type: :system do
  let!(:build) { create(:build) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
    visit project_path(build.project)
  end

  context "a new build gets created" do
    it "shows the new build" do
      new_build = create(:build, project: build.project)
      new_build.broadcast
      expect(page).to have_content(new_build.commit_hash)
    end
  end
end
