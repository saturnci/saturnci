require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "task events", type: :request do
  describe "POST /api/v1/worker_agents/tasks/:task_id/task_events" do
    let!(:task) { create(:run, :with_worker) }
    let!(:worker) { task.worker }

    it "increases the count of task events by 1" do
      expect {
        post(
          api_v1_worker_agents_task_task_events_path(task),
          params: { type: "worker_ready" },
          headers: worker_agents_api_authorization_headers(worker)
        )
      }.to change(TaskEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_worker_agents_task_task_events_path(task),
        params: { type: "worker_ready" },
        headers: worker_agents_api_authorization_headers(worker)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end
  end
end
