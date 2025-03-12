class CreateTestRunnerStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runner_statuses, id: :uuid do |t|
      t.references :test_runner, null: false, foreign_key: true, type: :uuid
      t.integer :type, null: false

      t.timestamps
    end

    add_index :test_runner_statuses, [:test_runner_id, :type], unique: true
  end
end
