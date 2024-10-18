require "rails_helper"

RSpec.describe BuildsController, type: :request do
  describe "GET #show" do
    context "a failed job is present" do
      let!(:build) { create(:build) }
      let!(:unfailed_job) { create(:job, build: build, order_index: 1) }
      let!(:failed_job) { create(:job, build: build, order_index: 2, test_report: "failed") }

      it "redirects to the first failed build" do
        login_as(build.project.user, scope: :user)
        get project_build_path(build.project, build)

        expect(response).to redirect_to(job_path(failed_job, "test_output"))
      end
    end

    context "a failed job is not present" do
      let!(:build) { create(:build) }
      let!(:unfailed_job) { create(:job, build: build) }

      it "redirects to the first job of the build" do
        login_as(build.project.user, scope: :user)
        get project_build_path(build.project, build)

        expect(response).to redirect_to(job_path(unfailed_job, "test_output"))
      end
    end
  end
end
