class AddFreeformColumnsToWorkerEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :worker_events, :name, :string
    add_column :worker_events, :notes, :text
  end
end
