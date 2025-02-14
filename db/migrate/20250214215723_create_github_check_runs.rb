class CreateGitHubCheckRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :github_check_runs, id: :uuid do |t|
      t.references :build, null: false, foreign_key: true, type: :uuid
      t.string :github_check_run_id, null: false

      t.timestamps
    end

    add_index :github_check_runs, [:build_id, :github_check_run_id], unique: true
  end
end
