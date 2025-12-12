class DropScreenshots < ActiveRecord::Migration[8.0]
  def change
    drop_table :screenshots
  end
end
