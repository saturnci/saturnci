class AddTerminateOnCompletionToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :terminate_on_completion, :boolean, default: true, null: false
  end
end
