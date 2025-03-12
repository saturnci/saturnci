class CreateTestRunnerEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runner_events, id: :uuid do |t|
      t.references :test_runner, null: false, foreign_key: true, type: :uuid
      t.integer :type

      t.timestamps
    end

    add_index :test_runner_events, [:test_runner_id, :type], unique: true
  end
end
