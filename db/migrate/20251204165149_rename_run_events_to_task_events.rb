class RenameRunEventsToTaskEvents < ActiveRecord::Migration[8.0]
  def change
    rename_table :run_events, :task_events
  end
end
