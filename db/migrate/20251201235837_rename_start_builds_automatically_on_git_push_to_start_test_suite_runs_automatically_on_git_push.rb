class RenameStartBuildsAutomaticallyOnGitPushToStartTestSuiteRunsAutomaticallyOnGitPush < ActiveRecord::Migration[8.0]
  def change
    rename_column :repositories, :start_builds_automatically_on_git_push, :start_test_suite_runs_automatically_on_git_push
  end
end
