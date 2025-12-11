require "rails_helper"

describe Nova do
  describe ".start_test_suite_run" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task_1) { create(:run, test_suite_run:, order_index: 1) }
    let!(:task_2) { create(:run, test_suite_run:, order_index: 2) }
    let!(:tasks) { [task_1, task_2] }

    before do
      allow(Nova).to receive(:create_k8s_job)
    end

    it "creates a worker for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to change { Worker.count }.by(2)
    end

    it "creates a WorkerAssignment for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to change { WorkerAssignment.count }.by(2)
    end

    it "creates a worker_requested task event for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to change { TaskEvent.where(type: "worker_requested").count }.by(2)
    end

    it "calls create_k8s_job for each task" do
      expect(Nova).to receive(:create_k8s_job).twice
      Nova.start_test_suite_run(test_suite_run, tasks)
    end
  end

  describe ".create_worker" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task) { create(:run, test_suite_run:) }

    it "returns the created worker" do
      worker = Nova.create_worker(task)
      expect(worker).to be_a(Worker)
      expect(worker).to be_persisted
    end

    it "creates a worker with an access token" do
      worker = Nova.create_worker(task)
      expect(worker.access_token).to be_present
    end

    it "creates a worker with a name containing the repo name" do
      worker = Nova.create_worker(task)
      expect(worker.name).to include(test_suite_run.repository.name.downcase)
    end

    it "creates a worker with a name containing the short task id" do
      worker = Nova.create_worker(task)
      expect(worker.name).to include(task.id[0..7])
    end

    it "sets task_id on the worker" do
      worker = Nova.create_worker(task)
      expect(worker.task_id).to eq(task.id)
    end
  end
end
