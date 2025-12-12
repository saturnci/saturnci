class CreateSentEmails < ActiveRecord::Migration[8.0]
  def change
    create_table :sent_emails, id: :uuid do |t|
      t.string :to, null: false
      t.string :subject, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
