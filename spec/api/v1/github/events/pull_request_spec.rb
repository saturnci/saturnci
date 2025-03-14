require "rails_helper"
include APIAuthenticationHelper

describe "Pull Request", type: :request do
  around do |example|
    perform_enqueued_jobs { example.run }
  end

  before do
    allow(TestRunner).to receive(:create_vm)
    allow(TestRunner).to receive(:available).and_return([create(:test_runner)])
  end

  let!(:project) do
    create(:project, github_repo_full_name: "user/test") do |project|
      project.user.github_accounts.create!(
        github_installation_id: "1111111"
      )
    end
  end

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
    api_authorization_headers(project.user).merge(
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

    it "creates a new build for the project" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: headers
        )
      }.to change { project.builds.count }.by(1)
    end

    it "sets the correct branch name, commit hash, commit message, and author name for the build" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      build = Build.last
      expect(build.branch_name).to eq("feature-branch")
      expect(build.commit_hash).to eq("abc123")
      expect(build.commit_message).to eq("Add new feature")
      expect(build.author_name).to eq("contributor")
    end
  end
end
