require "rails_helper"
require "octokit"

describe GitHubCheckRun do
  let!(:project) { create(:project, github_repo_full_name: "user/test") }
  let!(:build) { create(:build, project: project, commit_hash: "abc123") }
  let!(:github_client) { instance_double(Octokit::Client) }

  describe "#start!" do
    it "creates a check run and stores the check_run_id" do
      stubbed_response = double("Octokit::Response", id: 789)

      allow(github_client).to receive(:create_check_run)
        .with("user/test", "SaturnCI", "abc123", hash_including(status: "in_progress"))
        .and_return(stubbed_response)

      check_run = GitHubCheckRun.new(test_suite_run: build)
      check_run.start!(github_client:)

      expect(github_client).to have_received(:create_check_run)
      expect(check_run.reload.github_check_run_id).to eq("789")
    end
  end

  describe "#finish!" do
    it "updates the check run" do
      allow(github_client).to receive(:update_check_run)

      check_run = GitHubCheckRun.new(test_suite_run: build, github_check_run_id: "789")
      check_run.finish!(github_client:)

      expect(github_client).to have_received(:update_check_run)
    end
  end
end
