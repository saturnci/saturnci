class WorkerAssignment < ApplicationRecord
  self.table_name = "worker_assignments"

  belongs_to :worker
  belongs_to :task
  alias_method :run, :task
  alias_method :run=, :task=
  alias_attribute :run_id, :task_id
end
