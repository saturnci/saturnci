class RenameTestRunnerEventsToWorkerEvents < ActiveRecord::Migration[8.0]
  def change
    rename_table :test_runner_events, :worker_events
  end
end
