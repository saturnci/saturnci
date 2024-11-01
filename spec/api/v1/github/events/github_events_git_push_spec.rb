require "rails_helper"
include APIAuthenticationHelper

RSpec.describe "GitHub Events", type: :request do
  let!(:project) do
    create(:project, github_repo_full_name: "user/test") do |project|
      project.user.saturn_installations.create!(
        github_installation_id: "1111111"
      )
    end
  end

  before do
    job_machine_request_stub = instance_double("JobMachineRequest").tap do |stub|
      allow(stub).to receive(:create!)
    end

    allow(JobMachineRequest).to receive(:new).and_return(job_machine_request_stub)
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

    let(:headers) do
      api_authorization_headers.merge('CONTENT_TYPE' => 'application/json')
    end

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
      expect(build.branch_name).to eq('main')
    end

    context "multiple matching projects" do
      before do
        create(:project, github_repo_full_name: project.github_repo_full_name) do |project|
          project.user.saturn_installations.create!(
            github_installation_id: "1111112"
          )
        end
      end

      it "creates a new build for each project" do
        expect {
          post(
            "/api/v1/github_events",
            params: payload,
            headers: headers
          )
        }.to change { Build.count }.by(2)
      end
    end
  end
end
