class AddDeletedAtToRemainingTables < ActiveRecord::Migration[8.0]
  def change
    add_column :saturn_installations, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
    add_column :runs, :deleted_at, :datetime
  end
end
