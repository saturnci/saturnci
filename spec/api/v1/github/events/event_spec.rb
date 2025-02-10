require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub Events", type: :request do
  before do
    create(:project, github_repo_full_name: "johnsmith/myproject")
  end

  describe "installation event" do
    let!(:user) do
      create(:user, uid: "55555", provider: "github")
    end

    let!(:payload) do
      {
        "action" => "created",
        "repository" => {
          "full_name" => "johnsmith/myproject",
        },
        "installation" => {
          "id" => "12345",
          "account" => {
            "type" => "Organization",
          }
        },
        "sender" => {
          "id" => "55555",
        }
      }.to_json
    end

    it "creates an installation" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: api_authorization_headers(user).merge('CONTENT_TYPE' => 'application/json')
        )
      }.to change { GitHubAccount.count }.by(1)
    end
  end

  describe "git push event" do
    let!(:payload) do
      {
        "action" => "push",
        "ref": "refs/heads/main",
        "repository": {
          "id": 123,
          "name": "johnsmith",
          "full_name": "johnsmith/myproject"
        },
        "pusher": {
          "name": "johnsmith",
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

    let!(:user) { create(:user) }

    it "creates a GitHubEvent" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: api_authorization_headers(user).merge('CONTENT_TYPE' => 'application/json')
        )
      }.to change { GitHubEvent.count }.by(1)
    end
  end
end
