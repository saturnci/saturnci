class MakeSaturnInstallationsAccountNameNotNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :saturn_installations, :account_name, false
  end
end
