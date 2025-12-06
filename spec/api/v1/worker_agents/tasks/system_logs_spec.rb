require "rails_helper"
include APIAuthenticationHelper

describe "task system logs", type: :request do
  let!(:worker) { create(:worker) }
  let!(:task) { create(:run) }

  describe "GET /api/v1/worker_agents/tasks/:task_id/system_logs" do
    context "when system log exists" do
      let!(:runner_system_log) { create(:runner_system_log, run: task, content: "system log content") }

      it "returns the system log content" do
        get(
          api_v1_worker_agents_task_system_logs_path(task_id: task.id, format: :json),
          headers: worker_agents_api_authorization_headers(worker)
        )

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["content"]).to eq("system log content")
      end
    end

    context "when system log does not exist" do
      it "returns empty content" do
        get(
          api_v1_worker_agents_task_system_logs_path(task_id: task.id, format: :json),
          headers: worker_agents_api_authorization_headers(worker)
        )

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["content"]).to eq("")
      end
    end
  end
end
