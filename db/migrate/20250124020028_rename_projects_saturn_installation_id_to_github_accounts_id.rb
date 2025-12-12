class RenameProjectsSaturnInstallationIdToGitHubAccountsId < ActiveRecord::Migration[8.0]
  def change
    rename_column :projects, :saturn_installation_id, :github_account_id
  end
end
