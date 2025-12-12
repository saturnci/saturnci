class RenameJobMachineRSAKeyPathToRunnerRSAKeyPath < ActiveRecord::Migration[8.0]
  def change
    rename_column :runs, :job_machine_rsa_key_path, :runner_rsa_key_path
  end
end
