class WorkerEvent < ApplicationRecord
  self.table_name = "worker_events"
  self.inheritance_column = :_type_not_used
  belongs_to :worker

  enum :type, [
    :provision_request_sent,
    :ready_signal_received,
    :assignment_acknowledged,
    :error,
    :test_run_finished,
    :assignment_made,
  ]
end
