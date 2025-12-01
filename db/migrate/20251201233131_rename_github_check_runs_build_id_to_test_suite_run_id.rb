class RenameGitHubCheckRunsBuildIdToTestSuiteRunId < ActiveRecord::Migration[8.0]
  def change
    rename_column :github_check_runs, :build_id, :test_suite_run_id
  end
end
