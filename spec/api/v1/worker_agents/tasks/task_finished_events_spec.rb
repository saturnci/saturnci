require "rails_helper"
include APIAuthenticationHelper

describe "task finished events", type: :request do
  before do
    github_check_run_stub = instance_double("GitHubCheckRun").tap do |stub|
      allow(stub).to receive(:finish!)
    end

    allow(GitHubCheckRun).to receive(:new).and_return(github_check_run_stub)
    allow_any_instance_of(TestSuiteRun).to receive(:check_test_case_run_integrity!)
  end

  describe "POST /api/v1/worker_agents/tasks/:task_id/task_finished_events" do
    let!(:task) { create(:run, :with_worker) }
    let!(:worker) { task.worker }

    it "increases the count of task events by 1" do
      expect {
        post(
          api_v1_worker_agents_task_task_finished_events_path(task),
          headers: worker_agents_api_authorization_headers(worker)
        )
      }.to change(TaskEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_worker_agents_task_task_finished_events_path(task),
        headers: worker_agents_api_authorization_headers(worker)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end

    it "creates a charge for the task" do
      expect {
        post(
          api_v1_worker_agents_task_task_finished_events_path(task),
          headers: worker_agents_api_authorization_headers(worker)
        )
      }.to change { task.reload.charge.present? }.from(false).to(true)
    end
  end
end
