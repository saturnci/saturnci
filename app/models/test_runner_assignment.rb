class TestRunnerAssignment < ApplicationRecord
  belongs_to :worker, foreign_key: :test_runner_id, inverse_of: :test_runner_assignment
  belongs_to :run
end
