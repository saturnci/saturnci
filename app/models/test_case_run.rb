class TestCaseRun < ApplicationRecord
  belongs_to :run
  enum :status, %i[passed failed pending]

  def self.failed_first(test_case_runs)
    test_case_runs.sort_by do |tcr|
      [tcr.status, tcr.basename, tcr.line_number]
    end
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

  def basename
    File.basename(path)
  end
end
