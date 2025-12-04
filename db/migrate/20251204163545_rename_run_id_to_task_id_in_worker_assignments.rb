class RenameRunIdToTaskIdInWorkerAssignments < ActiveRecord::Migration[8.0]
  def change
    rename_column :worker_assignments, :run_id, :task_id
  end
end
