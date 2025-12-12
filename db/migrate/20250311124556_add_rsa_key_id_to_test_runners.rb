class AddRSAKeyIdToTestRunners < ActiveRecord::Migration[8.0]
  def change
    RunTestRunner.destroy_all
    TestRunner.destroy_all
    add_reference :test_runners, :rsa_key, foreign_key: true, null: false, type: :uuid
  end
end
