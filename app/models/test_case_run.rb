class TestCaseRun < ApplicationRecord
  belongs_to :run
  enum :status, %i[passed failed]

  def self.failed_first(test_case_runs)
    test_case_runs.sort_by { |tcr| [-tcr.status.to_i, tcr.id] }
  end

  def project
    run.build.project
  end

  def tidy_identifier
    identifier.gsub("\.\/spec\/", "")
  end

  def tidy_path
    path.gsub("\.\/", "")
  end
end
