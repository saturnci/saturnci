class RemoveSystemLogsFromRuns < ActiveRecord::Migration[8.0]
  def change
    remove_column :runs, :system_logs
  end
end
