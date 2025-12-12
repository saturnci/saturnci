class RenameRunWorkersToTaskWorkers < ActiveRecord::Migration[8.0]
  def change
    rename_table :run_workers, :task_workers
  end
end
