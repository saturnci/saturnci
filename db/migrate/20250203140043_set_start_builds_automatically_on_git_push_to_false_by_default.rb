class SetStartBuildsAutomaticallyOnGitPushToFalseByDefault < ActiveRecord::Migration[8.0]
  def change
    change_column_default :projects, :start_builds_automatically_on_git_push, false

    Project.update_all(start_builds_automatically_on_git_push: false)
  end
end
