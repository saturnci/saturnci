class RemoveRunIdFromRSAKeys < ActiveRecord::Migration[8.0]
  def change
    remove_column :rsa_keys, :run_id
  end
end
