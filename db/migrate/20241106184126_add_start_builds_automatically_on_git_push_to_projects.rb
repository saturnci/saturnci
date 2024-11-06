class AddStartBuildsAutomaticallyOnGitPushToProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :projects, :start_builds_automatically_on_git_push, :boolean, null: false, default: true
  end
end
