class DeleteTestRunnersWithoutAccessTokenAndMakeAccessTokenIdNotNull < ActiveRecord::Migration[8.0]
  def up
    TestRunner.where(access_token_id: nil).destroy_all
    change_column_null :test_runners, :access_token_id, false
  end

  def down
    change_column_null :test_runners, :access_token_id, true
  end
end
