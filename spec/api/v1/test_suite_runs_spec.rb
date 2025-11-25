require "rails_helper"
include APIAuthenticationHelper

describe "test suite runs", type: :request do
  let!(:test_suite_run) do
    create(:build, created_at: "2020-01-01T01:00:00")
  end

  let!(:user) { test_suite_run.project.user }

  before { user.update!(super_admin: true) }

  describe "GET /api/v1/test_suite_runs" do
    it "returns a 200 response" do
      get(
        api_v1_test_suite_runs_path,
        headers: api_authorization_headers(user)
      )
      expect(response).to have_http_status(200)
    end

    it "returns a list of test suite runs" do
      get(
        api_v1_test_suite_runs_path,
        headers: api_authorization_headers(user)
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["created_at"]).to eq("2020-01-01T01:00:00.000Z")
    end

    it "includes status" do
      get(
        api_v1_test_suite_runs_path,
        headers: api_authorization_headers(user)
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["status"]).to eq("Not Started")
    end
  end

  describe "PATCH /api/v1/test_suite_runs/:id" do
    it "updates expected example count from nil to 566" do
      expect(test_suite_run.dry_run_example_count).to be_nil

      patch(
        api_v1_test_suite_run_path(test_suite_run),
        params: { dry_run_example_count: 566 },
        headers: api_authorization_headers(user)
      )

      expect(test_suite_run.reload.dry_run_example_count).to eq(566)
    end

    it "returns 422 when updating dry_run_example_count to empty string" do
      test_suite_run.update!(dry_run_example_count: 353)

      patch(
        api_v1_test_suite_run_path(test_suite_run),
        params: { dry_run_example_count: "" },
        headers: api_authorization_headers(user)
      )

      expect(response).to have_http_status(422)
    end
  end

  describe "POST /api/v1/test_suite_runs" do
    let!(:repository) { create(:repository) }
    let!(:user) { repository.user }

    it "creates a test suite run" do
      expect {
        post(
          api_v1_test_suite_runs_path,
          params: {
            repository_id: repository.id,
            branch_name: "main",
            commit_hash: "abc123",
            commit_message: "Test commit",
            author_name: "Test Author"
          },
          headers: api_authorization_headers(user)
        )
      }.to change { TestSuiteRun.count }.by(1)
    end
  end
end
