class RenameTestRunnerAssignmentsToWorkerAssignments < ActiveRecord::Migration[8.0]
  def change
    rename_table :test_runner_assignments, :worker_assignments
  end
end
