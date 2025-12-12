class BackfillWorkerTaskId < ActiveRecord::Migration[8.0]
  def up
    execute <<-SQL
      UPDATE workers
      SET task_id = worker_assignments.task_id
      FROM worker_assignments
      WHERE worker_assignments.worker_id = workers.id
        AND workers.task_id IS NULL
    SQL
  end

  def down
  end
end
