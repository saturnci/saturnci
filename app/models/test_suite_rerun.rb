class TestSuiteRerun
  def self.create!(original_test_suite_run)
    TestSuiteRun.create!(
      original_test_suite_run.slice(
        :project,
        :branch_name,
        :commit_hash,
        :commit_message,
        :author_name
      )
    )
  end
end
