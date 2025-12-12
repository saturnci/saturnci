class AddWorkerArchitectureToRepositories < ActiveRecord::Migration[8.0]
  def up
    if column_exists?(:repositories, :worker_architecture_id)
      remove_reference :repositories, :worker_architecture
    end

    add_reference :repositories, :worker_architecture, foreign_key: true, type: :uuid, null: true

    terra = WorkerArchitecture.terra
    Repository.unscoped.update_all(worker_architecture_id: terra.id)

    change_column_null :repositories, :worker_architecture_id, false
  end

  def down
    remove_reference :repositories, :worker_architecture
  end
end
