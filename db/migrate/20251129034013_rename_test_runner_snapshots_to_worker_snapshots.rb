class RenameTestRunnerSnapshotsToWorkerSnapshots < ActiveRecord::Migration[8.0]
  def change
    rename_table :test_runner_snapshots, :worker_snapshots
  end
end
