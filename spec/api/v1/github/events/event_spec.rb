require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub Events", type: :request do
  describe "installation event" do
    before do
      user = create(:user, uid: "55555", provider: "github")
    end

    let!(:payload) do
      {
        "action" => "created",
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
          headers: api_authorization_headers.merge('CONTENT_TYPE' => 'application/json')
        )
      }.to change { SaturnInstallation.count }.by(1)
    end
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

    it "creates a GitHubEvent" do
      expect {
        post(
          "/api/v1/github_events",
          params: payload,
          headers: api_authorization_headers.merge('CONTENT_TYPE' => 'application/json')
        )
      }.to change { GitHubEvent.count }.by(1)
    end
  end
end
