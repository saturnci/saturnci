class ChangeScreenshotBuildIdToRunId < ActiveRecord::Migration[8.0]
  def change
    Screenshot.delete_all
    remove_column :screenshots, :build_id
    add_reference :screenshots, :run, foreign_key: true, null: false, type: :uuid
  end
end
