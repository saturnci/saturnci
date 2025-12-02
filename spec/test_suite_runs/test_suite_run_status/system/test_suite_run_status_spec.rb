require "rails_helper"

describe "Test suite run status", type: :system do
  include SaturnAPIHelper

  let!(:run) { create(:run, :with_test_runner) }
  let!(:user) { run.test_suite_run.repository.user }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    allow_any_instance_of(TestSuiteRun).to receive(:check_test_case_run_integrity!)
    login_as(user)
  end

  context "test suite run goes from running to passed" do
    context "no page refresh" do
      it "changes the status from running to passed" do
        visit repository_build_path(id: run.test_suite_run.id, repository_id: run.test_suite_run.repository.id)
        expect(page).to have_content("Running")

        run.update!(test_output: "COMMAND_EXIT_CODE=\"0\"")

        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(run.test_runner),
          path: api_v1_worker_agents_run_run_finished_events_path(run)
        )

        expect(page).to have_content("Passed")
      end
    end

    context "full page refresh after test suite run finishes" do
      it "maintains the 'passed' status" do
        visit repository_build_path(id: run.test_suite_run.id, repository_id: run.test_suite_run.repository.id)
        expect(page).to have_content("Running")

        run.update!(test_output: "COMMAND_EXIT_CODE=\"0\"")

        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(run.test_runner),
          path: api_v1_worker_agents_run_run_finished_events_path(run)
        )

        expect(page).to have_content("Passed") # to prevent race condition

        visit repository_build_path(id: run.test_suite_run.id, repository_id: run.test_suite_run.repository.id)
        expect(page).to have_content("Passed")
      end
    end
  end

  describe "test suite run list links" do
    context "test suite run goes from running to finished" do
      let!(:other_test_suite_run) { create(:build, repository: run.test_suite_run.repository) }
      let!(:other_run) { create(:run, :with_test_runner, build: other_test_suite_run) }

      it "maintains the currently active build" do
        visit repository_build_path(id: run.test_suite_run.id, repository_id: run.test_suite_run.repository.id)

        within ".test-suite-run-list" do
          expect(page).to have_content("Running", count: 2)
        end

        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(other_run.test_runner),
          path: api_v1_worker_agents_run_run_finished_events_path(other_run)
        )

        other_run_test_suite_run_link = PageObjects::TestSuiteRunLink.new(page, other_test_suite_run)
        expect(other_run_test_suite_run_link).not_to be_active
      end
    end
  end

  describe "elapsed time" do
    context "running test suite run" do
      it "does not show the elapsed test suite run time" do
        visit repository_build_path(run.test_suite_run.repository, run.test_suite_run)
        expect(page).to have_selector("[data-elapsed-test-suite-run-time-target='value']")
      end
    end

    context "finished test suite run" do
      it "shows the elapsed test suite run time" do
        run.update!(exit_code: 0)
        visit repository_build_path(run.test_suite_run.repository, run.test_suite_run)
        expect(page).not_to have_selector("[data-elapsed-test-suite-run-time-target='value']")
      end
    end

    context "when the test suite run goes from running to finished" do
      before do
        allow_any_instance_of(TestSuiteRun).to receive(:duration_formatted).and_return("3m 40s")
        visit repository_build_path(run.test_suite_run.repository, run.test_suite_run)
      end

      it "changes the elapsed time from counting to not counting" do
        # We expect the page not to have "3m 40s" because,
        # before the test suite run finishes, the counter will be counting
        expect(page).not_to have_content("3m 40s")

        http_request(
          api_authorization_headers: worker_agents_api_authorization_headers(run.test_runner),
          path: api_v1_worker_agents_run_run_finished_events_path(run)
        )

        # After the test suite run finishes, the counter will have
        # stopped counting and we just see the static duration
        expect(page).to have_content("3m 40s")
      end
    end
  end
end
