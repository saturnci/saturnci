require "rails_helper"
include APIAuthenticationHelper

describe "Tasks", type: :request do
  describe "GET /api/v1/worker_agents/tasks/:id" do
    let!(:worker) { create(:worker) }
    let!(:task) { create(:run) }

    let!(:project_secret) do
      create(
        :project_secret,
        repository: task.repository,
        key: "DATABASE_URL",
        value: "postgres://localhost"
      )
    end

    it "returns the task info" do
      get(
        api_v1_worker_agents_task_path(id: task.id, format: :json),
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(:ok)

      response_body = JSON.parse(response.body)
      expect(response_body["github_repo_full_name"]).to eq(task.repository.github_repo_full_name)
      expect(response_body["branch_name"]).to eq(task.test_suite_run.branch_name)
      expect(response_body["commit_hash"]).to eq(task.test_suite_run.commit_hash)
      expect(response_body["github_installation_id"]).to eq(task.repository.github_account.github_installation_id)
      expect(response_body["rspec_seed"]).to eq(task.test_suite_run.seed)
      expect(response_body["run_order_index"]).to eq(task.order_index)
      expect(response_body["number_of_concurrent_runs"]).to eq(task.repository.concurrency)
      expect(response_body["env_vars"][project_secret.key]).to eq(project_secret.value)
    end
  end
end
