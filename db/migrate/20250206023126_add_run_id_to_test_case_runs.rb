class AddRunIdToTestCaseRuns < ActiveRecord::Migration[8.0]
  def change
    add_reference :test_case_runs, :run, type: :uuid, foreign_key: true, null: false
  end
end
