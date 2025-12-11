class WorkerEvent < ApplicationRecord
  self.table_name = "worker_events"
  self.inheritance_column = :_type_not_used
  belongs_to :worker

  enum :type, [
    :ready_signal_received,
    :error,
    :task_finished,
  ]
end
