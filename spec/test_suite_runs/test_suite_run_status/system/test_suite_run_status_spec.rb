require "rails_helper"

describe "Test suite run status", type: :system do
  include SaturnAPIHelper

  let!(:task) { create(:task, :with_worker) }
  let!(:user) { task.test_suite_run.repository.user }

  before do
    allow(Nova).to receive(:delete_k8s_job)
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    allow_any_instance_of(TestSuiteRun).to receive(:check_test_case_run_integrity!)
    login_as(user)
  end

  context "test suite run goes from running to passed" do
    context "no page refresh" do
      it "changes the status from running to passed" do
        visit repository_build_path(id: task.test_suite_run.id, repository_id: task.test_suite_run.repository.id)
        expect(page).to have_content("Running")

        task.update!(json_output: { "summary" => { "failure_count" => 0 } }.to_json)

        perform_enqueued_jobs do
          http_request(
            api_authorization_headers: worker_agents_api_authorization_headers(task.worker),
            path: api_v1_worker_agents_task_task_finished_events_path(task_id: task.id)
          )
        end

        expect(page).to have_content("Passed")
      end
    end

    context "full page refresh after test suite run finishes" do
      it "maintains the 'passed' status" do
        visit repository_build_path(id: task.test_suite_run.id, repository_id: task.test_suite_run.repository.id)
        expect(page).to have_content("Running")

        task.update!(json_output: { "summary" => { "failure_count" => 0 } }.to_json)

        perform_enqueued_jobs do
          http_request(
            api_authorization_headers: worker_agents_api_authorization_headers(task.worker),
            path: api_v1_worker_agents_task_task_finished_events_path(task_id: task.id)
          )
        end

        expect(page).to have_content("Passed") # to prevent race condition

        visit repository_build_path(id: task.test_suite_run.id, repository_id: task.test_suite_run.repository.id)
        expect(page).to have_content("Passed")
      end
    end
  end

  describe "test suite run list links" do
    context "test suite run goes from running to finished" do
      let!(:other_test_suite_run) { create(:build, repository: task.test_suite_run.repository) }
      let!(:other_task) { create(:run, :with_worker, build: other_test_suite_run) }

      it "maintains the currently active build" do
        visit repository_build_path(id: task.test_suite_run.id, repository_id: task.test_suite_run.repository.id)

        within ".test-suite-run-list" do
          expect(page).to have_content("Running", count: 2)
        end

        perform_enqueued_jobs do
          http_request(
            api_authorization_headers: worker_agents_api_authorization_headers(other_task.worker),
            path: api_v1_worker_agents_task_task_finished_events_path(task_id: other_task.id)
          )
        end

        other_task_test_suite_run_link = PageObjects::TestSuiteRunLink.new(page, other_test_suite_run)
        expect(other_task_test_suite_run_link).not_to be_active
      end
    end
  end

  describe "elapsed time" do
    context "running test suite run" do
      it "does not show the elapsed test suite run time" do
        visit repository_build_path(task.test_suite_run.repository, task.test_suite_run)
        expect(page).to have_selector("[data-elapsed-test-suite-run-time-target='value']")
      end
    end

    context "finished test suite run" do
      it "shows the elapsed test suite run time" do
        task.update!(exit_code: 0)
        visit repository_build_path(task.test_suite_run.repository, task.test_suite_run)
        expect(page).not_to have_selector("[data-elapsed-test-suite-run-time-target='value']")
      end
    end

    context "when the test suite run goes from running to finished" do
      before do
        allow_any_instance_of(TestSuiteRun).to receive(:duration_formatted).and_return("3m 40s")
        visit repository_build_path(task.test_suite_run.repository, task.test_suite_run)
      end

      it "changes the elapsed time from counting to not counting" do
        # We expect the page not to have "3m 40s" because,
        # before the test suite run finishes, the counter will be counting
        expect(page).not_to have_content("3m 40s")

        perform_enqueued_jobs do
          http_request(
            api_authorization_headers: worker_agents_api_authorization_headers(task.worker),
            path: api_v1_worker_agents_task_task_finished_events_path(task_id: task.id)
          )
        end

        # After the test suite run finishes, the counter will have
        # stopped counting and we just see the static duration
        expect(page).to have_content("3m 40s")
      end
    end
  end
end
