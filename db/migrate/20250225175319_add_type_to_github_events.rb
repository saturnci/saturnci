class AddTypeToGitHubEvents < ActiveRecord::Migration[8.0]
  def change
    GitHubEvent.delete_all
    add_column :github_events, :type, :string, null: false
  end
end
