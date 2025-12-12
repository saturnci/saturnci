require "rails_helper"

RSpec.describe "Task#name" do
  describe "test suite run has 8 or fewer tasks" do
    let!(:test_suite_run) { create(:test_suite_run) }

    before do
      8.times { |i| create(:task, test_suite_run:, order_index: i + 1) }
    end

    it "returns 'Worker n'" do
      task = test_suite_run.tasks.find_by(order_index: 3)
      expect(task.name).to eq("Worker 3")
    end
  end

  describe "test suite run has more than 8 tasks" do
    let!(:test_suite_run) { create(:test_suite_run) }

    before do
      9.times { |i| create(:task, test_suite_run:, order_index: i + 1) }
    end

    describe "first task" do
      it "returns 'Worker 1'" do
        task = test_suite_run.tasks.find_by(order_index: 1)
        expect(task.name).to eq("Worker 1")
      end
    end

    describe "subsequent tasks" do
      it "returns just the number" do
        task = test_suite_run.tasks.find_by(order_index: 3)
        expect(task.name).to eq("3")
      end
    end
  end
end
