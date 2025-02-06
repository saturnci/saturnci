class TestCaseRun < ApplicationRecord
  enum :status, %i[passed failed]

  def tidy_identifier
    identifier.gsub("\.\/spec\/", "")
  end
end
