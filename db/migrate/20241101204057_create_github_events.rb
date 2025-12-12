class CreateGitHubEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :github_events, id: :uuid do |t|
      t.jsonb :body, null: false

      t.timestamps
    end
  end
end
