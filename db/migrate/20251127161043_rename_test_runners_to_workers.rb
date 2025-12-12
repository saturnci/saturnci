class RenameTestRunnersToWorkers < ActiveRecord::Migration[8.0]
  def change
    rename_table :test_runners, :workers
  end
end
