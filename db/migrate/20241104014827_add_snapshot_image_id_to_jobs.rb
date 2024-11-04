class AddSnapshotImageIdToJobs < ActiveRecord::Migration[8.0]
  def change
    add_column :jobs, :snapshot_image_id, :string
  end
end
