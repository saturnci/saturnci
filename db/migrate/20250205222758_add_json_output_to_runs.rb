class AddJSONOutputToRuns < ActiveRecord::Migration[8.0]
  def change
    add_column :runs, :json_output, :jsonb
  end
end
