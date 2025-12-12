class CreateWorkerArchitectures < ActiveRecord::Migration[8.0]
  def change
    create_table :worker_architectures, id: :uuid do |t|
      t.string :slug, null: false
      t.timestamps
    end

    add_index :worker_architectures, :slug, unique: true

    reversible do |dir|
      dir.up do
        execute <<-SQL
          INSERT INTO worker_architectures (id, slug, created_at, updated_at)
          VALUES
            (gen_random_uuid(), 'terra', NOW(), NOW()),
            (gen_random_uuid(), 'nova', NOW(), NOW())
        SQL
      end
    end
  end
end
