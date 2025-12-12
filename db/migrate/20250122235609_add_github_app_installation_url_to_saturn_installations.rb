class AddGitHubAppInstallationUrlToSaturnInstallations < ActiveRecord::Migration[8.0]
  def change
    add_column :saturn_installations, :github_app_installation_url, :string
  end
end
