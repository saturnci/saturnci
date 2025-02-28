require "rails_helper"

describe "Build status", type: :system do
  include SaturnAPIHelper

  let!(:run) { create(:run) }
  let!(:user) { run.build.project.user }

  before { login_as(user) }

  context "build goes from running to passed" do
    context "no page refresh" do
      it "changes the status from running to passed" do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        expect(page).to have_content("Running")

        run.update!(test_output: "COMMAND_EXIT_CODE=\"0\"")

        http_request(
          api_authorization_headers: api_authorization_headers(user),
          path: api_v1_run_run_finished_events_path(run)
        )

        expect(page).to have_content("Passed")
      end
    end

    context "full page refresh after build finishes" do
      it "maintains the 'passed' status" do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        expect(page).to have_content("Running")

        run.update!(test_output: "COMMAND_EXIT_CODE=\"0\"")

        http_request(
          api_authorization_headers: api_authorization_headers(user),
          path: api_v1_run_run_finished_events_path(run)
        )

        expect(page).to have_content("Passed") # to prevent race condition

        visit project_build_path(id: run.build.id, project_id: run.build.project.id)
        expect(page).to have_content("Passed")
      end
    end
  end

  describe "build list links" do
    context "build goes from running to finished" do
      let!(:other_build) { create(:build, project: run.build.project) }
      let!(:other_run) { create(:run, build: other_build) }

      it "maintains the currently active build" do
        visit project_build_path(id: run.build.id, project_id: run.build.project.id)

        within ".test-suite-run-list" do
          expect(page).to have_content("Running", count: 2)
        end

        http_request(
          api_authorization_headers: api_authorization_headers(user),
          path: api_v1_run_run_finished_events_path(other_run)
        )

        other_run_test_suite_run_link = PageObjects::TestSuiteRunLink.new(page, other_build)
        expect(other_run_test_suite_run_link).not_to be_active
      end
    end
  end

  describe "elapsed time" do
    context "running build" do
      it "does not show the elapsed build time" do
        visit project_build_path(run.build.project, run.build)
        expect(page).to have_selector("[data-elapsed-build-time-target='value']")
      end
    end

    context "finished build" do
      it "shows the elapsed build time" do
        run.update!(test_report: "passed")
        visit project_build_path(run.build.project, run.build)
        expect(page).not_to have_selector("[data-elapsed-build-time-target='value']")
      end
    end

    context "when the build goes from running to finished" do
      before do
        allow_any_instance_of(Build).to receive(:duration_formatted).and_return("3m 40s")
        visit project_build_path(run.build.project, run.build)
      end

      it "changes the elapsed time from counting to not counting" do
        # We expect the page not to have "3m 40s" because,
        # before the build finishes, the counter will be counting
        expect(page).not_to have_content("3m 40s")

        http_request(
          api_authorization_headers: api_authorization_headers(user),
          path: api_v1_run_run_finished_events_path(run)
        )

        # After the build finishes, the counter will have
        # stopped counting and we just see the static duration
        expect(page).to have_content("3m 40s")
      end
    end
  end
end
