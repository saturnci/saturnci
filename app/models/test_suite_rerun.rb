class TestSuiteRerun
  def self.create!(original_test_suite_run, started_by_user: nil)
    TestSuiteRun.create!(
      original_test_suite_run.slice(
        :project,
        :branch_name,
        :commit_hash,
        :commit_message,
        :author_name
      ).merge(started_by_user:)
    )
  end
end
