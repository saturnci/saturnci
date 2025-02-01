class RemoveRunAPIToken < ActiveRecord::Migration[8.0]
  def change
    remove_column :runs, :api_token
  end
end
