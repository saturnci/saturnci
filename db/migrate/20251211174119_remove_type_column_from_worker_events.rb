class RemoveTypeColumnFromWorkerEvents < ActiveRecord::Migration[8.0]
  def change
    remove_column :worker_events, :type, :integer
  end
end
