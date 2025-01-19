class ChangeSaturnInstallationsNameToAccountName < ActiveRecord::Migration[8.0]
  def change
    rename_column :saturn_installations, :name, :account_name
  end
end
