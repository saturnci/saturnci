class RenameTestRunnerIdToWorkerIdInRunWorkers < ActiveRecord::Migration[8.0]
  def change
    rename_column :run_workers, :test_runner_id, :worker_id
  end
end
