class AddInstallationResponsePayloadToGitHubAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :github_accounts, :installation_response_payload, :jsonb
  end
end
