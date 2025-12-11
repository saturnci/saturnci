require "rails_helper"

describe "GET /api/v1/test_suite_runs/:id", type: :request do
  let!(:user) { create(:user, super_admin: true) }
  let!(:personal_access_token) { create(:personal_access_token, user:) }
  let!(:test_suite_run) { create(:build) }
  let!(:run) { create(:run, test_suite_run:) }

  let(:credentials) do
    ActionController::HttpAuthentication::Basic.encode_credentials(
      user.id.to_s,
      personal_access_token.access_token.value
    )
  end

  context "with worker events" do
    let!(:worker) { create(:worker) }
    let!(:worker_assignment) { create(:worker_assignment, task: run, worker:) }
    let!(:worker_event) { create(:worker_event, worker:, name: "task_fetched") }

    it "includes the worker event name in the response" do
      get(
        api_v1_test_suite_run_path(test_suite_run.id[0..8]),
        headers: { "Authorization" => credentials }
      )

      body = JSON.parse(response.body)
      expect(body["tasks"].first["worker_events"].first["name"]).to eq("task_fetched")
    end
  end

  context "with a failed test" do
    let!(:failed_test_case_run) do
      create(
        :test_case_run,
        run:,
        status: "failed",
        path: "spec/models/user_spec.rb",
        line_number: 42,
        description: "validates presence of email",
        exception: "RSpec::Expectations::ExpectationNotMetError",
        exception_message: "expected nil to be present",
        exception_backtrace: "spec/models/user_spec.rb:42"
      )
    end

    it "returns the failed test details" do
      get(
        api_v1_test_suite_run_path(test_suite_run.id[0..8]),
        headers: { "Authorization" => credentials }
      )

      body = JSON.parse(response.body)
      expect(body["failed_tests"].first["path"]).to eq("spec/models/user_spec.rb")
      expect(body["failed_tests"].first["line_number"]).to eq(42)
      expect(body["failed_tests"].first["exception_message"]).to eq("expected nil to be present")
    end
  end
end
