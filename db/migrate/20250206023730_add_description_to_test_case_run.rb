class AddDescriptionToTestCaseRun < ActiveRecord::Migration[8.0]
  def change
    add_column :test_case_runs, :description, :string, null: false
  end
end
