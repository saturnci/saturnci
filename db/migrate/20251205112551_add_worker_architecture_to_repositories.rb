class AddWorkerArchitectureToRepositories < ActiveRecord::Migration[8.0]
  def up
    terra = WorkerArchitecture.find_by!(slug: "terra")
    add_reference :repositories, :worker_architecture, foreign_key: true, type: :uuid, default: terra.id
  end

  def down
    remove_reference :repositories, :worker_architecture
  end
end
