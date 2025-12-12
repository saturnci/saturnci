class CreateGitHubOAuthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :github_oauth_tokens, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :value, null: false

      t.timestamps
    end

    add_index :github_oauth_tokens, [:user_id, :value], unique: true
  end
end
