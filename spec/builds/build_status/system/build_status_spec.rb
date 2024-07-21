require "rails_helper"

describe "Build status", type: :system do
  include SaturnAPIHelper

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

  context "when the build goes from running to finished" do
    before do
      allow_any_instance_of(Build).to receive(:duration_formatted).and_return("3m 40s")
      visit project_build_path(job.build.project, job.build)
    end

    it "goes from counting to not counting" do
      # We expect the page not to have "3m 40s" because,
      # before the build finishes, the counter will be counting
      expect(page).not_to have_content("3m 40s")

      http_request(
        api_authorization_headers: api_authorization_headers,
        path: api_v1_job_job_finished_events_path(job)
      )

      # After the build finishes, the counter will have
      # stopped counting and we just see the static duration
      expect(page).to have_content("3m 40s")
    end
  end
end
