class DeleteOrphanedWorkersAndMakeTaskIdNotNullable < ActiveRecord::Migration[8.0]
  def up
    execute "DELETE FROM workers WHERE task_id IS NULL"
    change_column_null :workers, :task_id, false
  end

  def down
    change_column_null :workers, :task_id, true
  end
end
