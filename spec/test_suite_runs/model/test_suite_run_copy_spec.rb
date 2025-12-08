require "rails_helper"

describe TestSuiteRunCopy do
  let!(:original_test_suite_run) { create(:test_suite_run) }

  let!(:task_1) do
    create(
      :task,
      test_suite_run: original_test_suite_run,
      order_index: 1
    )
  end

  let!(:task_2) do
    create(
      :task,
      test_suite_run: original_test_suite_run,
      order_index: 2
    )
  end

  it "creates a test suite run with the same number of tasks" do
    copy = TestSuiteRunCopy.create!(original_test_suite_run)
    expect(copy.tasks.count).to eq(2)
  end
end
