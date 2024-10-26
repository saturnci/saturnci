class AddExitCodeToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :exit_code, :integer
  end
end
