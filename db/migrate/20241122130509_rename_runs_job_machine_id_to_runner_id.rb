class RenameRunsJobMachineIdToRunnerId < ActiveRecord::Migration[8.0]
  def change
    rename_column :runs, :job_machine_id, :runner_id
  end
end
