require "rails_helper"
include APIAuthenticationHelper

describe "run finished events", type: :request do
  before do
    github_check_run_stub = instance_double("GitHubCheckRun").tap do |stub|
      allow(stub).to receive(:finish!)
    end

    allow(GitHubCheckRun).to receive(:new).and_return(github_check_run_stub)
    allow_any_instance_of(TestSuiteRun).to receive(:check_test_case_run_integrity!)
  end

  describe "POST /api/v1/test_runner_agents/runs/:id/run_finished_events" do
    let!(:run) { create(:run, :with_test_runner) }
    let!(:test_runner) { run.test_runner }

    it "increases the count of run events by 1" do
      expect {
        post(
          api_v1_test_runner_agents_run_run_finished_events_path(run),
          headers: test_runner_agents_api_authorization_headers(test_runner)
        )
      }.to change(RunEvent, :count).by(1)
    end

    it "returns an empty 200 response" do
      post(
        api_v1_test_runner_agents_run_run_finished_events_path(run),
        headers: test_runner_agents_api_authorization_headers(test_runner)
      )
      expect(response).to have_http_status(200)
      expect(response.body).to be_empty
    end

    it "creates a charge for the run" do
      expect {
        post(
          api_v1_test_runner_agents_run_run_finished_events_path(run),
          headers: test_runner_agents_api_authorization_headers(test_runner)
        )
      }.to change { run.reload.charge.present? }.from(false).to(true)
    end
  end
end
