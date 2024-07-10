require "rails_helper"

describe "Elapsed build time", type: :system do
  let!(:job) { create(:job) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  context "running build" do
    it "does not show the elapsed build time" do
      visit project_build_path(job.build.project, job.build)
      expect(page).to have_selector("[data-elapsed-build-time-target='value']")
    end
  end

  context "finished build" do
    it "shows the elapsed build time" do
      job.update!(test_report: "passed")
      visit project_build_path(job.build.project, job.build)
      expect(page).not_to have_selector("[data-elapsed-build-time-target='value']")
    end
  end
end
