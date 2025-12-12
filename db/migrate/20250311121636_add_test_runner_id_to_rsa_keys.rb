class AddTestRunnerIdToRSAKeys < ActiveRecord::Migration[8.0]
  def change
    add_reference :rsa_keys, :test_runner, foreign_key: true, type: :uuid
  end
end
