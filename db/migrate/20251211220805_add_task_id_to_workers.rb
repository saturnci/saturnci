class AddTaskIdToWorkers < ActiveRecord::Migration[8.0]
  def change
    add_reference :workers, :task, null: true, foreign_key: true, type: :uuid
  end
end
