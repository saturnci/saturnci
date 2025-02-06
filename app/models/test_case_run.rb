class TestCaseRun < ApplicationRecord
  enum :status, %i[passed failed]
end
