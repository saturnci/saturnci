class RenameTestRunnerIdToWorkerIdInWorkerAssignments < ActiveRecord::Migration[8.0]
  def change
    rename_column :worker_assignments, :test_runner_id, :worker_id
  end
end
