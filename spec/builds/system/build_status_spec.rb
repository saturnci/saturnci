require "rails_helper"

describe "Build status", type: :system do
  let!(:job) { create(:job) }

  before do
    user = create(:user)
    login_as(user, scope: :user)
  end

  context "build goes from running to passed" do
    it "shows the most current status" do
      visit project_build_path(id: job.build.id, project_id: job.build.project.id)
      expect(page).to have_content("Running")

      job.update!(test_report: "good")
      job.job_events.create!(type: "job_finished")

      visit project_build_path(id: job.build.id, project_id: job.build.project.id)
      expect(page).to have_content("Passed")
    end
  end
end
