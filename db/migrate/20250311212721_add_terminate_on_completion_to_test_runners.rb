class AddTerminateOnCompletionToTestRunners < ActiveRecord::Migration[8.0]
  def change
    add_column :test_runners, :terminate_on_completion, :boolean, default: true, null: false
  end
end
