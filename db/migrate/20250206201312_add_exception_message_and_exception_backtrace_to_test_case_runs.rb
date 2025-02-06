class AddExceptionMessageAndExceptionBacktraceToTestCaseRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :test_case_runs, :exception_message, :text
    add_column :test_case_runs, :exception_backtrace, :text
  end
end
