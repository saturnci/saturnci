require "rails_helper"
include APIAuthenticationHelper

describe "worker agents targeted test cases", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }
  let!(:task_1) { create(:run, test_suite_run:, order_index: 1) }
  let!(:task_2) { create(:run, test_suite_run:, order_index: 2) }
  let!(:worker) { create(:worker) }

  describe "POST /api/v1/worker_agents/test_suite_runs/:id/targeted_test_cases" do
    let!(:test_files) { ["spec/models/user_spec.rb", "spec/models/post_spec.rb", "spec/models/comment_spec.rb"] }

    it "returns divided test files keyed by task order_index" do
      post(
        api_v1_worker_agents_test_suite_run_targeted_test_cases_path(test_suite_run_id: test_suite_run.id),
        params: { test_files: test_files },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body["1"].size).to eq(2)
      expect(body["2"].size).to eq(1)
    end
  end
end
