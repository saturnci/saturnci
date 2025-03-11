class RemoveTestRunnerIdFromRSAKeys < ActiveRecord::Migration[8.0]
  def change
    remove_column :rsa_keys, :test_runner_id
  end
end
