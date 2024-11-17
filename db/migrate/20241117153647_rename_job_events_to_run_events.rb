class RenameJobEventsToRunEvents < ActiveRecord::Migration[8.0]
  def change
    rename_table :job_events, :run_events
  end
end
