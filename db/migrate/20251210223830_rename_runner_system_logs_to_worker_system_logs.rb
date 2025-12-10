class RenameRunnerSystemLogsToWorkerSystemLogs < ActiveRecord::Migration[8.0]
  def change
    rename_table :runner_system_logs, :worker_system_logs
  end
end
