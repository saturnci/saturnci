class AddConcurrencyToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :concurrency, :integer, default: 2, null: false
  end
end
