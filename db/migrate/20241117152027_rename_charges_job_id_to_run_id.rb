class RenameChargesJobIdToRunId < ActiveRecord::Migration[8.0]
  def change
    rename_column :charges, :job_id, :run_id
  end
end
