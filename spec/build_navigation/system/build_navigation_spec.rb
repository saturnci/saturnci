require "rails_helper"

describe "Build navigation", type: :system do
  let!(:first_build) { create(:build, :with_job) }
  let!(:second_build) { create(:build, :with_job, project: first_build.project) }

  before do
    login_as(first_build.project.user, scope: :user)
  end

  describe "clicking on second build after having visited first build" do
    before do
      visit project_build_path(first_build.project, first_build)
      click_on "build_link_#{second_build.id}"
      expect(page).to have_content(pane_heading(second_build)) # to prevent race condition
    end

    it "retains the first build in the build list" do
      expect(page).to have_content(first_build.project.name)
    end

    it "after refresh, keeps second build in detail pane" do
      visit current_url
      expect(page).to have_content(pane_heading(second_build))
    end

    it "after refresh, keeps left pane (build list)" do
      visit current_url
      expect(page).to have_content(first_build.project.name)
    end
  end

  def pane_heading(build)
    "Commit: #{build.commit_hash[0..7]}"
  end
end
