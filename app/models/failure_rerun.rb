class FailureRerun < ApplicationRecord
  belongs_to :original_test_suite_run, class_name: "TestSuiteRun"
  belongs_to :test_suite_run
end
