class CreateTestFailureScreenshots < ActiveRecord::Migration[8.0]
  def change
    create_table :test_failure_screenshots, id: :uuid do |t|
      t.uuid :test_case_run_id, null: false
      t.string :path, null: false

      t.timestamps
    end
    add_index :test_failure_screenshots, [:test_case_run_id, :path], unique: true
    add_foreign_key :test_failure_screenshots, :test_case_runs
  end
end
