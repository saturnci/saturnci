class RenameTotalExampleCountToDryRunExampleCount < ActiveRecord::Migration[8.0]
  def change
    rename_column :test_suite_runs, :expected_total_example_count, :dry_run_example_count
  end
end
