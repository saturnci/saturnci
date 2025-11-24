class CreateNewPersonalAccessTokens < ActiveRecord::Migration[8.0]
  def change
    drop_table :personal_access_tokens

    create_table :personal_access_tokens, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.uuid :access_token_id, null: false

      t.timestamps
    end

    add_foreign_key :personal_access_tokens, :users
    add_foreign_key :personal_access_tokens, :access_tokens
    add_index :personal_access_tokens, :user_id
    add_index :personal_access_tokens, :access_token_id
  end
end
