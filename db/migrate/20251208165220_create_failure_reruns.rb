class CreateFailureReruns < ActiveRecord::Migration[8.0]
  def change
    create_table :failure_reruns, id: :uuid do |t|
      t.references :original_test_suite_run, null: false, foreign_key: { to_table: :test_suite_runs }, type: :uuid
      t.references :test_suite_run, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end

    add_index :failure_reruns, [:original_test_suite_run_id, :test_suite_run_id], unique: true
  end
end
