class AddJobMachineRSAKeyPathToJobs < ActiveRecord::Migration[7.1]
  def change
    add_column :jobs, :job_machine_rsa_key_path, :string
  end
end
