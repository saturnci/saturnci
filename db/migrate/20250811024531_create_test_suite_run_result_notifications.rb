class CreateTestSuiteRunResultNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :test_suite_run_result_notifications, id: :uuid do |t|
      t.references :test_suite_run, null: false, foreign_key: true, type: :uuid
      t.references :sent_email, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false

      t.timestamps
    end
    
    add_index :test_suite_run_result_notifications, [:test_suite_run_id, :email], unique: true, name: "index_tsrrn_on_test_suite_run_and_email"
  end
end
