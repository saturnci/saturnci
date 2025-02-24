require "rails_helper"
include APIAuthenticationHelper

describe "run finished events", type: :request do
  before do
    github_check_run_stub = instance_double("GitHubCheckRun").tap do |stub|
      allow(stub).to receive(:finish!)
    end

    allow(GitHubCheckRun).to receive(:new).and_return(github_check_run_stub)
  end

  describe "POST /api/v1/runs/:id/run_finished_events" do
    let!(:run) { create(:run) }
    let!(:user) { run.build.project.user }

    it "increases the count of run events by 1" do
      expect {
        post(
          api_v1_run_run_finished_events_path(run),
          headers: api_authorization_headers(user)
        )
      }.to change(RunEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_run_run_finished_events_path(run),
        headers: api_authorization_headers(user)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end

    it "creates a charge for the run" do
      expect {
        post(
          api_v1_run_run_finished_events_path(run),
          headers: api_authorization_headers(user)
        )
      }.to change { run.reload.charge.present? }.from(false).to(true)
    end
  end
end
