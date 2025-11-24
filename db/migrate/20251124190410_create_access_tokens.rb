class CreateAccessTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :access_tokens, id: :uuid do |t|
      t.string :value, null: false

      t.timestamps
    end
  end
end
