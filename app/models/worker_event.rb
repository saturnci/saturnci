class WorkerEvent < ApplicationRecord
  self.table_name = "worker_events"
  belongs_to :worker
end
