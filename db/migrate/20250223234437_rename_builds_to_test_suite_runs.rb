class RenameBuildsToTestSuiteRuns < ActiveRecord::Migration[8.0]
  def change
    rename_table :builds, :test_suite_runs
  end
end
