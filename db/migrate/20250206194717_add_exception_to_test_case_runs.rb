class AddExceptionToTestCaseRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :test_case_runs, :exception, :text
  end
end
