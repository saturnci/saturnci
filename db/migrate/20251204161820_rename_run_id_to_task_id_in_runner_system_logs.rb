class RenameRunIdToTaskIdInRunnerSystemLogs < ActiveRecord::Migration[8.0]
  def change
    rename_column :runner_system_logs, :run_id, :task_id
  end
end
