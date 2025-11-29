class WorkerAssignment < ApplicationRecord
  self.table_name = "worker_assignments"

  belongs_to :worker, inverse_of: :test_runner_assignment
  belongs_to :run
end
