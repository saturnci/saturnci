require "rails_helper"
include APIAuthenticationHelper

describe "Check Suite", type: :request do
  let!(:project) do
    create(:project, github_repo_full_name: "user/test") do |project|
      project.user.github_accounts.create!(
        github_installation_id: "1111111"
      )
    end
  end

  let!(:payload) do
    {
      "action": "requested",
      "repository": {
        "id": 123,
        "name": "test",
        "full_name": "user/test"
      },
      "check_suite": {
        "id": 456,
        "head_branch": "main",
        "head_sha": "abc123",
        "status": "queued",
        "head_commit": {
          "id": "abc123",
          "message": "Initial commit",
          "author": {
            "name": "Author Name",
            "email": "author@example.com"
          }
        }
      }
    }.to_json
  end

  let!(:headers) do
    api_authorization_headers(project.user).merge(
      "CONTENT_TYPE" => "application/json",
      "X-GitHub-Event" => "check_suite"
    )
  end

  describe "check suite event" do
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

    it "sets the branch name for the build" do
      post(
        "/api/v1/github_events",
        params: payload,
        headers: headers
      )

      build = Build.last
      expect(build.branch_name).to eq("main")
    end
  end
end
