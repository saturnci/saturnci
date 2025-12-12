class RenameTasksBuildIdToTestSuiteRunId < ActiveRecord::Migration[8.0]
  def change
    rename_column :tasks, :build_id, :test_suite_run_id
  end
end
