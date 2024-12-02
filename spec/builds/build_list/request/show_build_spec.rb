require "rails_helper"

RSpec.describe BuildsController, type: :request do
  describe "GET #show" do
    context "a failed run is present" do
      let!(:build) { create(:build) }
      let!(:unfailed_run) { create(:run, :passed, build: build, order_index: 1) }
      let!(:failed_run) { create(:run, :failed, build: build, order_index: 2) }

      it "redirects to the first failed build" do
        login_as(build.project.user, scope: :user)
        get project_build_path(build.project, build)

        expect(response).to redirect_to(run_path(failed_run, "test_output"))
      end
    end

    context "no failed run is present" do
      let!(:build) { create(:build) }
      let!(:unfailed_run) { create(:run, build: build) }

      it "redirects to the first run of the build" do
        login_as(build.project.user, scope: :user)
        get project_build_path(build.project, build)

        expect(response).to redirect_to(run_path(unfailed_run, "test_output"))
      end
    end

    context "no runs are present" do
      let!(:build) { create(:build) }

      it "does not raise an error" do
        login_as(build.project.user, scope: :user)
        expect { get project_build_path(build.project, build) }.not_to raise_error
      end
    end
  end
end
