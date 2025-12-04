require "rails_helper"
include APIAuthenticationHelper

describe "worker agents test suite runs", type: :request do
  let!(:test_suite_run) { create(:build, created_at: "2020-01-01T01:00:00") }
  let!(:worker) { create(:worker) }

  describe "PATCH /api/v1/worker_agents/test_suite_runs/:id" do
    it "updates expected example count from nil to 566" do
      expect(test_suite_run.dry_run_example_count).to be_nil

      patch(
        api_v1_worker_agents_test_suite_run_path(test_suite_run),
        params: { dry_run_example_count: 566 },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(test_suite_run.reload.dry_run_example_count).to eq(566)
    end

    it "returns 422 when updating dry_run_example_count to empty string" do
      test_suite_run.update!(dry_run_example_count: 353)

      patch(
        api_v1_worker_agents_test_suite_run_path(test_suite_run),
        params: { dry_run_example_count: "" },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(422)
    end
  end
end
