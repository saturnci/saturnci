require "rails_helper"

describe "test suite run status", type: :model do
  before { Rails.cache.clear }

  context "test suite run is finished" do
    let!(:test_suite_run) { build(:test_suite_run) }
    let!(:task_1) { build(:task, test_suite_run: test_suite_run, order_index: 1) }
    let!(:task_2) { build(:task, test_suite_run: test_suite_run, order_index: 2) }

    context "status is set" do
      it "does not incur the expense of calculated_status" do
        test_suite_run.status
        expect(test_suite_run).not_to receive(:calculated_status)
        test_suite_run.status
      end
    end
  end

  context "no tasks" do
    it "is 'Not Started'" do
      test_suite_run = build(:test_suite_run)
      expect(test_suite_run.status).to eq("Not Started")
    end
  end

  context "some tasks" do
    let!(:test_suite_run) { create(:test_suite_run) }

    context "all tasks have passed" do
      let!(:task_1) { create(:task, :passed, test_suite_run: test_suite_run, order_index: 1) }
      let!(:task_2) { create(:task, :passed, test_suite_run: test_suite_run, order_index: 2) }

      it "is passed" do
        expect(test_suite_run.status).to eq("Passed")
      end
    end

    context "any tasks have failed" do
      let!(:task_1) { create(:task, :passed, test_suite_run: test_suite_run, order_index: 1) }
      let!(:task_2) { create(:task, :failed, test_suite_run: test_suite_run, order_index: 2) }

      it "is failed" do
        expect(test_suite_run.status).to eq("Failed")
      end
    end

    context "some tasks are running, no tasks are failed" do
      let!(:task_1) { create(:task, test_suite_run: test_suite_run, order_index: 1) }
      let!(:task_2) { create(:task, :failed, test_suite_run: test_suite_run, order_index: 2) }

      it "is running" do
        expect(test_suite_run.status).to eq("Running")
      end
    end

    context "there are no tasks" do
      it "is not started" do
        allow(test_suite_run).to receive(:runs).and_return(Task.none)

        expect(test_suite_run.status).to eq("Not Started")
      end
    end

    describe "database caching" do
      context "cached_status matches calculated_status" do
        let!(:task_1) { create(:task, :passed, test_suite_run: test_suite_run, order_index: 1) }
        let!(:task_2) { create(:task, :passed, test_suite_run: test_suite_run, order_index: 2) }

        before do
          test_suite_run.update!(cached_status: "Passed")
        end

        it "does not update the test suite run" do
          expect(test_suite_run).not_to receive(:update!)
          test_suite_run.status
        end
      end
    end
  end
end
