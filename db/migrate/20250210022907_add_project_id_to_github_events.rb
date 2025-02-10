class AddProjectIdToGitHubEvents < ActiveRecord::Migration[8.0]
  def change
    GitHubEvent.destroy_all
    add_reference :github_events, :project, type: :uuid, foreign_key: true, null: false
  end
end
