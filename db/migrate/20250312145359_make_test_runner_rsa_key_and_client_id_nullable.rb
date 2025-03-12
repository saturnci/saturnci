class MakeTestRunnerRSAKeyAndClientIdNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :test_runners, :rsa_key_id, true
    change_column_null :test_runners, :cloud_id, true
  end
end
