class TaskWorker < ApplicationRecord
  self.table_name = "task_workers"
  belongs_to :task
  alias_method :run, :task
  alias_method :run=, :task=
  belongs_to :worker
end
