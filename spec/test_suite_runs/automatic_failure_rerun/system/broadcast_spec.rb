require "rails_helper"

describe "Automatic failure rerun broadcast", type: :system do
  include SaturnAPIHelper

  let!(:test_suite_run) { create(:test_suite_run, dry_run_example_count: 1) }
  let!(:task) { create(:run, :with_worker, test_suite_run:) }
  let!(:failed_test_case_run) { create(:test_case_run, run: task, status: "failed") }
  let!(:user) { test_suite_run.repository.user }

  before do
    allow_any_instance_of(User).to receive(:can_access_repository?).and_return(true)
    login_as(user)
  end

  it "broadcasts the rerun test suite run to the list" do
    visit repository_path(test_suite_run.repository)

    within ".test-suite-run-list" do
      expect(page).to have_content(test_suite_run.commit_hash)
    end

    http_request(
      api_authorization_headers: worker_agents_api_authorization_headers(task.worker),
      path: api_v1_worker_agents_task_task_finished_events_path(task_id: task.id)
    )

    within ".test-suite-run-list" do
      expect(page).to have_selector(".test-suite-run-link", count: 2)
    end
  end
end
