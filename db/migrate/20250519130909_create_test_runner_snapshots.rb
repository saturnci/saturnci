class CreateTestRunnerSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runner_snapshots, id: :uuid do |t|
      t.string :cloud_id, null: false
      t.string :os, null: false
      t.string :size, null: false

      t.timestamps
    end
  end
end
