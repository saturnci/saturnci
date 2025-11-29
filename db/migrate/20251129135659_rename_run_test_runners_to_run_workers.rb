class RenameRunTestRunnersToRunWorkers < ActiveRecord::Migration[8.0]
  def change
    rename_table :run_test_runners, :run_workers
  end
end
