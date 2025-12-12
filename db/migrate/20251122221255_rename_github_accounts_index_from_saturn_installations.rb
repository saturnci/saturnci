class RenameGitHubAccountsIndexFromSaturnInstallations < ActiveRecord::Migration[8.0]
  def change
    rename_index :github_accounts, :index_saturn_installations_on_user_and_github_id, :index_github_accounts_on_user_and_github_id
  end
end
