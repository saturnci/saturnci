class RenameProjectIdToRepositoryIdInTestSuiteRuns < ActiveRecord::Migration[8.0]
  def change
    rename_column :test_suite_runs, :project_id, :repository_id
  end
end
