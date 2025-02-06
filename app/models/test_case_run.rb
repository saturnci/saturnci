class TestCaseRun < ApplicationRecord
  belongs_to :run
  enum :status, %i[passed failed]

  def project
    run.build.project
  end

  def tidy_identifier
    identifier.gsub("\.\/spec\/", "")
  end
end
