class DropCompleteSyslogs < ActiveRecord::Migration[8.0]
  def change
    remove_column :runs, :complete_syslog
  end
end
