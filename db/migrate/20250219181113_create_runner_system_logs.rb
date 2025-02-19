class CreateRunnerSystemLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :runner_system_logs, id: :uuid do |t|
      t.references :run, null: false, foreign_key: true, type: :uuid
      t.text :content, null: false, default: ""

      t.timestamps
    end
  end
end
