require "rails_helper"
include APIAuthenticationHelper

describe "Push", type: :request do
  let!(:project) do
    create(:project, github_repo_full_name: "user/test") do |project|
      project.user.github_accounts.create!(
        github_installation_id: "1111111"
      )
    end
  end

  before do
    runner_request_stub = instance_double("RunSpecificRunnerRequest").tap do |stub|
      allow(stub).to receive(:execute!)
    end

    allow(RunSpecificRunnerRequest).to receive(:new).and_return(runner_request_stub)
  end

  describe "git push event" do
    let!(:payload) do
      {
        "ref": "refs/heads/main",
        "repository": {
          "id": 123,
          "name": "test",
          "full_name": "user/test",
        },
        "pusher": {
          "name": "user",
        },
        "head_commit": {
          "id": "abc123",
          "message": "commit message",
          "author": {
            "name": "author name",
            "email": "author email",
          },
        },
      }.to_json
    end

    let!(:headers) do
      api_authorization_headers(project.user).merge(
        "CONTENT_TYPE" => "application/json",
        "X-GitHub-Event" => "push"
      )
    end

    it "returns 200" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      expect(response).to have_http_status(:ok)
    end

    it "creates a new test suite run for the project" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: headers
        )
      }.to change { project.test_suite_runs.count }.by(1)
    end

    it "sets the branch name for the test suite run" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      test_suite_run = TestSuiteRun.last
      expect(test_suite_run.branch_name).to eq("main")
    end

    context "multiple matching projects" do
      before do
        create(:project, github_repo_full_name: project.github_repo_full_name) do |project|
          project.user.github_accounts.create!(
            github_installation_id: "1111112"
          )
        end
      end

      it "creates a new test suite run for each project" do
        expect {
          post(
            "/api/v1/github_events",
            params: payload,
            headers: headers
          )
        }.to change { TestSuiteRun.count }.by(2)
      end
    end
  end
end
