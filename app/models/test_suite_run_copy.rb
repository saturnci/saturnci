class TestSuiteRunCopy
  def self.create!(original_test_suite_run)
    ActiveRecord::Base.transaction do
      new_test_suite_run = TestSuiteRun.create!(
        original_test_suite_run.slice(
          :repository,
          :branch_name,
          :commit_hash,
          :commit_message,
          :author_name
        )
      )

      original_test_suite_run.tasks.each do |task|
        Task.create!(
          test_suite_run: new_test_suite_run,
          order_index: task.order_index
        )
      end

      new_test_suite_run
    end
  end
end
