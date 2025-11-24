class CreatePersonalAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :personal_access_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :value, null: false

      t.timestamps
    end

    add_index :personal_access_tokens, [:user_id, :value], unique: true
  end
end
