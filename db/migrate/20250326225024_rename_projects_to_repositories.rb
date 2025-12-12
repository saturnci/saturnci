class RenameProjectsToRepositories < ActiveRecord::Migration[8.0]
  def change
    rename_table :projects, :repositories
  end
end
