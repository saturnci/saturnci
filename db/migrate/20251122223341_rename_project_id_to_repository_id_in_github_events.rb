class RenameProjectIdToRepositoryIdInGitHubEvents < ActiveRecord::Migration[8.0]
  def change
    rename_column :github_events, :project_id, :repository_id
  end
end
