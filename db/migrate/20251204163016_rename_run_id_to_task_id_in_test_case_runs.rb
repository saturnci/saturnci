class RenameRunIdToTaskIdInTestCaseRuns < ActiveRecord::Migration[8.0]
  def change
    rename_column :test_case_runs, :run_id, :task_id
  end
end
