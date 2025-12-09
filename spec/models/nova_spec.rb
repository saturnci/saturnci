require "rails_helper"

describe Nova do
  describe ".start_test_suite_run" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task_1) { create(:run, test_suite_run:, order_index: 1) }
    let!(:task_2) { create(:run, test_suite_run:, order_index: 2) }
    let!(:tasks) { [task_1, task_2] }

    it "enqueues a CreateWorkerJob for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to have_enqueued_job(Nova::CreateWorkerJob).exactly(2).times
    end

    it "enqueues CreateWorkerJob with the task id" do
      Nova.start_test_suite_run(test_suite_run, tasks)

      expect(Nova::CreateWorkerJob).to have_been_enqueued.with(task_1.id)
      expect(Nova::CreateWorkerJob).to have_been_enqueued.with(task_2.id)
    end
  end
end
