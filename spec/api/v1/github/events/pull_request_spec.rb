require "rails_helper"
include APIAuthenticationHelper

describe "Pull Request", type: :request do
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  before do
    allow(Nova).to receive(:create_k8s_job)
  end

  let!(:repository) do
    create(:repository, github_repo_full_name: "user/test") do |repository|
      repository.user.github_accounts.create!(
        github_installation_id: "1111111"
      )
    end
  end

  let!(:personal_access_token) { create(:personal_access_token, user: repository.user) }

  let!(:payload) do
    {
      "action": "opened",
      "repository": {
        "id": 123,
        "name": "test",
        "full_name": "user/test"
      },
      "pull_request": {
        "id": 456,
        "title": "Add new feature",
        "head": {
          "ref": "feature-branch",
          "sha": "abc123"
        },
        "user": {
          "login": "contributor"
        }
      }
    }.to_json
  end

  let!(:headers) do
    api_authorization_headers(personal_access_token).merge(
      "CONTENT_TYPE" => "application/json",
      "X-GitHub-Event" => "pull_request"
    )
  end

  before do
    runner_request_stub = instance_double("RunSpecificRunnerRequest").tap do |stub|
      allow(stub).to receive(:execute!)
    end
    allow(RunSpecificRunnerRequest).to receive(:new).and_return(runner_request_stub)

    allow(GitHubCheckRun).to receive(:new).and_return(double(start!: true))
  end

  describe "pull request opened event" do
    it "returns 200" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      expect(response).to have_http_status(:ok)
    end

    it "creates a new test suite run for the repository" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: headers
        )
      }.to change { repository.test_suite_runs.count }.by(1)
    end

    it "sets the correct branch name, commit hash, commit message, and author name for the test suite run" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      test_suite_run = TestSuiteRun.last
      expect(test_suite_run.branch_name).to eq("feature-branch")
      expect(test_suite_run.commit_hash).to eq("abc123")
      expect(test_suite_run.commit_message).to eq("Add new feature")
      expect(test_suite_run.author_name).to eq("contributor")
    end

    context "when create_github_checks_automatically_upon_pull_request_creation is enabled" do
      before do
        repository.update!(create_github_checks_automatically_upon_pull_request_creation: true)
      end

      it "creates a GitHub check run" do
        expect(GitHubCheckRun).to receive(:new).and_return(double(start!: true))

        post(
          "/api/v1/github_events",
          params: payload,
          headers: headers
        )
      end
    end

    context "when create_github_checks_automatically_upon_pull_request_creation is disabled" do
      before do
        repository.update!(create_github_checks_automatically_upon_pull_request_creation: false)
      end

      it "does not create a GitHub check run" do
        expect(GitHubCheckRun).not_to receive(:new)

        post(
          "/api/v1/github_events",
          params: payload,
          headers: headers
        )
      end
    end
  end
end
