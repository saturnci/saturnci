class RenameRunsToTasks < ActiveRecord::Migration[8.0]
  def change
    rename_table :runs, :tasks
  end
end
