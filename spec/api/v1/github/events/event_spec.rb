require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub Events", type: :request do
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
