require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "builds", type: :request do
  let!(:build) do
    create(:build, created_at: "2020-01-01T01:00:00")
  end

  describe "GET /api/v1/builds" do
    it "returns a 200 response" do
      get(
        api_v1_builds_path,
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
    end

    it "returns a list of builds" do
      get(
        api_v1_builds_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["created_at"]).to eq("2020-01-01T01:00:00.000Z")
    end

    it "includes status" do
      get(
        api_v1_builds_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["status"]).to eq("Running")
    end
  end
end
