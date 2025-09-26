class AddExpectedTotalExampleCountToTestSuiteRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :test_suite_runs, :expected_total_example_count, :integer
  end
end
