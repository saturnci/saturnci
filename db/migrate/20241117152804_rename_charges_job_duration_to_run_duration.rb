class RenameChargesJobDurationToRunDuration < ActiveRecord::Migration[8.0]
  def change
    rename_column :charges, :job_duration, :run_duration
  end
end
