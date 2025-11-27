class TestRunnerAssignment < ApplicationRecord
  belongs_to :test_runner, class_name: "TestRunner", inverse_of: :test_runner_assignment
  belongs_to :run
end
