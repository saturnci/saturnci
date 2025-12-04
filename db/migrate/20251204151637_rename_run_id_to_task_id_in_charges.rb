class RenameRunIdToTaskIdInCharges < ActiveRecord::Migration[8.0]
  def change
    rename_column :charges, :run_id, :task_id
  end
end
