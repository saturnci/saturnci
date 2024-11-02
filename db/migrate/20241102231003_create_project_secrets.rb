class CreateProjectSecrets < ActiveRecord::Migration[8.0]
  def change
    create_table :project_secrets, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.string :key, null: false
      t.string :value, null: false

      t.timestamps
    end

    add_index :project_secrets, [:project_id, :key], unique: true
  end
end
