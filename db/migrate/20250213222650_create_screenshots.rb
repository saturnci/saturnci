class CreateScreenshots < ActiveRecord::Migration[8.0]
  def change
    create_table :screenshots, id: :uuid do |t|
      t.references :build, null: false, foreign_key: true, type: :uuid
      t.string :path

      t.timestamps
    end

    add_index :screenshots, :build_id, unique: true, name: "unique_index_screenshots_on_build_id"
  end
end
