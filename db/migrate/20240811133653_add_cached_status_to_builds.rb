class AddCachedStatusToBuilds < ActiveRecord::Migration[7.1]
  def change
    add_column :builds, :cached_status, :string
  end
end
