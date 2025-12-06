require "rails_helper"

describe Nova do
  describe ".start_test_suite_run" do
    let!(:test_suite_run) { create(:test_suite_run) }

    it "creates a task for each concurrent run" do
      test_suite_run.repository.update!(concurrency: 3)

      expect { Nova.start_test_suite_run(test_suite_run) }
        .to change { Task.count }.by(3)
    end

    it "creates a worker for each task" do
      test_suite_run.repository.update!(concurrency: 2)

      expect { Nova.start_test_suite_run(test_suite_run) }
        .to change { Worker.count }.by(2)
    end

    it "creates a WorkerAssignment for each task" do
      test_suite_run.repository.update!(concurrency: 2)

      expect { Nova.start_test_suite_run(test_suite_run) }
        .to change { WorkerAssignment.count }.by(2)
    end

    it "associates tasks with workers via WorkerAssignment" do
      Nova.start_test_suite_run(test_suite_run)

      task = test_suite_run.tasks.first
      expect(task.worker_assignment).to be_present
      expect(task.worker).to be_present
    end

    it "associates workers with tasks via WorkerAssignment" do
      Nova.start_test_suite_run(test_suite_run)

      task = test_suite_run.tasks.first
      worker = task.worker
      expect(worker.worker_assignment).to be_present
      expect(worker.task.id).to eq(task.id)
    end

    it "creates a runner_requested event for each task" do
      test_suite_run.repository.update!(concurrency: 2)
      Nova.start_test_suite_run(test_suite_run)

      test_suite_run.tasks.each do |task|
        expect(task.task_events.runner_requested.count).to eq(1)
      end
    end

    it "enqueues a CreateK8sPodJob for each worker/task pair" do
      test_suite_run.repository.update!(concurrency: 2)

      expect { Nova.start_test_suite_run(test_suite_run) }
        .to have_enqueued_job(Nova::CreateK8sPodJob).exactly(2).times
    end
  end
end
