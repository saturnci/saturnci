class AddAPITokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :api_token, :string
  end
end
