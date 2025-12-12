class AddCreateGitHubCheckRunsOnPullRequestsToRepositories < ActiveRecord::Migration[8.0]
  def change
    add_column :repositories, :create_github_check_runs_on_pull_requests, :boolean, null: false, default: false
  end
end
