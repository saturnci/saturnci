class AddCompleteSyslogToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :complete_syslog, :text
  end
end
