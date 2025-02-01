class AddAPITokenToBuilds < ActiveRecord::Migration[8.0]
  def change
    add_column :builds, :api_token, :string
  end
end
