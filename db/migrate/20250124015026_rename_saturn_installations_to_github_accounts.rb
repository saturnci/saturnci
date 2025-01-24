class RenameSaturnInstallationsToGitHubAccounts < ActiveRecord::Migration[8.0]
  def change
    rename_table :saturn_installations, :github_accounts
  end
end
