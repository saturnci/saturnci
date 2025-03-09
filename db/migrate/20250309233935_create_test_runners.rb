class CreateTestRunners < ActiveRecord::Migration[8.0]
  def change
    create_table :test_runners, id: :uuid do |t|
      t.string :name, null: false
      t.string :cloud_id, null: false

      t.timestamps
    end

    add_index :test_runners, :name, unique: true
    add_index :test_runners, :cloud_id, unique: true
  end
end
