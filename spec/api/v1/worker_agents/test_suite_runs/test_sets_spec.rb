require "rails_helper"
include APIAuthenticationHelper

describe "worker agents test sets", type: :request do
  let!(:test_suite_run) { create(:test_suite_run) }
  let!(:task_1) { create(:run, test_suite_run:, order_index: 1) }
  let!(:task_2) { create(:run, test_suite_run:, order_index: 2) }
  let!(:worker) { create(:worker) }

  describe "POST /api/v1/worker_agents/test_suite_runs/:id/test_set" do
    let!(:test_files) { ["spec/models/user_spec.rb", "spec/models/post_spec.rb", "spec/models/comment_spec.rb"] }

    it "returns divided test files keyed by task order_index" do
      post(
        api_v1_worker_agents_test_suite_run_test_set_path(test_suite_run_id: test_suite_run.id),
        params: { test_files: test_files },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      grouped_tests = body["grouped_tests"]
      expect(grouped_tests["1"].size).to eq(2)
      expect(grouped_tests["2"].size).to eq(1)
    end

    it "returns dry_run_example_count in the response" do
      post(
        api_v1_worker_agents_test_suite_run_test_set_path(test_suite_run_id: test_suite_run.id),
        params: { test_files: test_files },
        headers: worker_agents_api_authorization_headers(worker)
      )

      body = JSON.parse(response.body)
      expect(body["dry_run_example_count"]).to eq(3)
    end

    it "sets dry_run_example_count to the number of test files" do
      post(
        api_v1_worker_agents_test_suite_run_test_set_path(test_suite_run_id: test_suite_run.id),
        params: { test_files: test_files },
        headers: worker_agents_api_authorization_headers(worker)
      )

      expect(test_suite_run.reload.dry_run_example_count).to eq(3)
    end

    context "when the test suite run is a failure rerun" do
      let!(:original_test_suite_run) { create(:test_suite_run) }
      let!(:original_task) { create(:run, test_suite_run: original_test_suite_run) }
      let!(:passed_test_case_run) { create(:test_case_run, run: original_task, status: "passed", identifier: "spec/models/user_spec.rb[1]") }
      let!(:failed_test_case_run) { create(:test_case_run, run: original_task, status: "failed", identifier: "spec/models/post_spec.rb[1]") }
      let!(:failure_rerun) { create(:failure_rerun, original_test_suite_run: original_test_suite_run, test_suite_run: test_suite_run) }

      it "returns only the failed test identifiers from the original run" do
        post(
          api_v1_worker_agents_test_suite_run_test_set_path(test_suite_run_id: test_suite_run.id),
          params: { test_files: test_files },
          headers: worker_agents_api_authorization_headers(worker)
        )

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        grouped_tests = body["grouped_tests"]
        all_tests = grouped_tests.values.flatten
        expect(all_tests).to eq(["spec/models/post_spec.rb[1]"])
      end
    end
  end
end
