class CreateRunTestRunners < ActiveRecord::Migration[8.0]
  def change
    create_table :run_test_runners, id: :uuid do |t|
      t.references :run, null: false, foreign_key: true, type: :uuid
      t.references :test_runner, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :run_test_runners, [:run_id], unique: true, name: 'run_test_runners_run_id'
    add_index :run_test_runners, [:test_runner_id], unique: true, name: 'run_test_runners_test_runner_id'
  end
end
