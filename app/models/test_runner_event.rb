class TestRunnerEvent < ApplicationRecord
  self.inheritance_column = :_type_not_used
  belongs_to :worker, foreign_key: :test_runner_id

  enum :type, [
    :provision_request_sent,
    :ready_signal_received,
    :assignment_acknowledged,
    :error,
    :test_run_finished,
    :assignment_made,
  ]
end
