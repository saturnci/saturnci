class AddAPITokenToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :api_token, :string
  end
end
