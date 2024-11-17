require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "jobs", type: :request do
  let!(:job) do
    create(
      :job,
      created_at: "2020-01-01T01:00:00",
      build: create(:build, commit_message: "Do stuff")
    )
  end

  describe "GET /api/v1/jobs" do
    it "returns a 200 response" do
      get(
        api_v1_jobs_path,
        headers: api_authorization_headers
      )
      expect(response).to have_http_status(200)
    end

    it "returns a list of jobs" do
      get(
        api_v1_jobs_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["created_at"]).to eq("2020-01-01T01:00:00.000Z")
    end

    it "includes build status" do
      get(
        api_v1_jobs_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["status"]).to eq("Running")
    end

    it "includes build id" do
      get(
        api_v1_jobs_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["build_id"]).to eq(job.build.id)
    end

    it "includes commit message" do
      get(
        api_v1_jobs_path,
        headers: api_authorization_headers
      )

      response_body = JSON.parse(response.body)
      expect(response_body[0]["build_commit_message"]).to eq("Do stuff")
    end
  end
end
