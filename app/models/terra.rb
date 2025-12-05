module Terra
  def self.start_test_suite_run(test_suite_run)
    ActiveRecord::Base.transaction do
      test_suite_run.save!

      test_suite_run.repository.concurrency.times.map do |i|
        Task.create!(test_suite_run:, order_index: i + 1)
      end
    end

    test_suite_run
  end
end
