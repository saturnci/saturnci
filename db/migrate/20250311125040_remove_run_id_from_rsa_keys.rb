class RemoveRunIdFromRSAKeys < ActiveRecord::Migration[8.0]
  def change
    Cloud::RSAKey.destroy_all
    remove_column :rsa_keys, :run_id
  end
end
