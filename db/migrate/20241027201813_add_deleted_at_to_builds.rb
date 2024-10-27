class AddDeletedAtToBuilds < ActiveRecord::Migration[8.0]
  def change
    add_column :builds, :deleted_at, :datetime
  end
end
