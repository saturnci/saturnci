class CreateTestRunnerAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runner_assignments, id: :uuid do |t|
      t.references :test_runner, null: false, foreign_key: true, type: :uuid
      t.references :run, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :test_runner_assignments, :test_runner_id, unique: true, name: :unique_test_runners
    add_index :test_runner_assignments, :run_id, unique: true, name: :unique_runs
  end
end
