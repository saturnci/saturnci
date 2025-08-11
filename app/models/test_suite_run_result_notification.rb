class TestSuiteRunResultNotification < ApplicationRecord
  belongs_to :test_suite_run
  belongs_to :sent_email
end
