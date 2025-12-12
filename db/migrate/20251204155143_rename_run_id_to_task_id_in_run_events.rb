class RenameRunIdToTaskIdInRunEvents < ActiveRecord::Migration[8.0]
  def change
    rename_column :run_events, :run_id, :task_id
  end
end
