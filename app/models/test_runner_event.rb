class TestRunnerEvent < ApplicationRecord
  self.inheritance_column = :_type_not_used
  belongs_to :test_runner

  enum :type, [
    :provisioning,
  ]
end
