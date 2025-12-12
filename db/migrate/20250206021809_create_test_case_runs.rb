class CreateTestCaseRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :test_case_runs, id: :uuid do |t|
      t.string :identifier, null: false
      t.string :path, null: false
      t.integer :line_number, null: false
      t.integer :status, null: false
      t.float :duration, null: false

      t.timestamps
    end
  end
end
