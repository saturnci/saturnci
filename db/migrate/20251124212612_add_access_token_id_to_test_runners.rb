class AddAccessTokenIdToTestRunners < ActiveRecord::Migration[8.0]
  def change
    add_column :test_runners, :access_token_id, :uuid
  end
end
