class RemoveFinishedAtFromBuilds < ActiveRecord::Migration[7.1]
  def change
    remove_column :builds, :finished_at
  end
end
