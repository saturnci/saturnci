class CreateRSAKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :rsa_keys, id: :uuid do |t|
      t.references :run, null: false, foreign_key: true, type: :uuid
      t.text :public_key_value, null: false
      t.text :private_key_value, null: false

      t.timestamps
    end
  end
end
