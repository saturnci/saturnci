require "rails_helper"

describe Nova do
  describe ".create_worker" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task) { create(:run, test_suite_run:) }

    it "creates a worker with an access token" do
      Nova.create_worker(task)
      expect(task.worker.access_token).to be_present
    end

    it "creates a worker with a name containing the repo name" do
      Nova.create_worker(task)
      expect(task.worker.name).to include(test_suite_run.repository.name.downcase)
    end

    it "creates a worker with a name containing the short task id" do
      Nova.create_worker(task)
      expect(task.worker.name).to include(task.id[0..7])
    end

    it "creates a WorkerAssignment linking the task and worker" do
      Nova.create_worker(task)
      expect(task.worker_assignment.worker).to eq(task.worker)
    end
  end

  describe ".start_test_suite_run" do
    let!(:test_suite_run) { create(:test_suite_run) }
    let!(:task_1) { create(:run, test_suite_run:, order_index: 1) }
    let!(:task_2) { create(:run, test_suite_run:, order_index: 2) }
    let!(:tasks) { [task_1, task_2] }

    it "creates a worker for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to change { Worker.count }.by(2)
    end

    it "creates a WorkerAssignment for each task" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to change { WorkerAssignment.count }.by(2)
    end

    it "associates tasks with workers via WorkerAssignment" do
      Nova.start_test_suite_run(test_suite_run, tasks)

      task = test_suite_run.tasks.first
      expect(task.worker_assignment).to be_present
      expect(task.worker).to be_present
    end

    it "associates workers with tasks via WorkerAssignment" do
      Nova.start_test_suite_run(test_suite_run, tasks)

      task = test_suite_run.tasks.first
      worker = task.worker
      expect(worker.worker_assignment).to be_present
      expect(worker.task.id).to eq(task.id)
    end

    it "enqueues a CreateK8sPodJob for each worker/task pair" do
      expect { Nova.start_test_suite_run(test_suite_run, tasks) }
        .to have_enqueued_job(Nova::CreateK8sPodJob).exactly(2).times
    end
  end
end
