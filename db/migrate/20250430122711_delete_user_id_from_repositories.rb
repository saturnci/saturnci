class DeleteUserIdFromRepositories < ActiveRecord::Migration[8.0]
  def change
    remove_column :repositories, :user_id
  end
end
