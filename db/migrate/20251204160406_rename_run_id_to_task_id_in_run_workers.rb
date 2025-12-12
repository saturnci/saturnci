class RenameRunIdToTaskIdInRunWorkers < ActiveRecord::Migration[8.0]
  def change
    rename_column :run_workers, :run_id, :task_id
  end
end
