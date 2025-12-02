class RenameCreateGitHubCheckRunsOnPullRequestsToCreateGitHubChecksAutomaticallyUponPullRequestCreation < ActiveRecord::Migration[8.0]
  def change
    rename_column :repositories, :create_github_check_runs_on_pull_requests, :create_github_checks_automatically_upon_pull_request_creation
  end
end
