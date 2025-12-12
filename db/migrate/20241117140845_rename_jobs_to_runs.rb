class RenameJobsToRuns < ActiveRecord::Migration[8.0]
  def change
    rename_table :jobs, :runs
  end
end
