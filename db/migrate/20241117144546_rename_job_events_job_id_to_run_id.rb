class RenameJobEventsJobIdToRunId < ActiveRecord::Migration[8.0]
  def change
    rename_column :job_events, :job_id, :run_id
  end
end
