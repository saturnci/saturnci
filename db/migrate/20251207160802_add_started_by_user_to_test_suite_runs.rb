class AddStartedByUserToTestSuiteRuns < ActiveRecord::Migration[8.0]
  def change
    add_reference :test_suite_runs, :started_by_user, foreign_key: { to_table: :users }, type: :uuid
  end
end
