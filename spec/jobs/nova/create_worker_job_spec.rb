require "rails_helper"

describe Nova::CreateWorkerJob do
  let!(:test_suite_run) { create(:test_suite_run) }
  let!(:task) { create(:run, test_suite_run:) }

  before do
    allow(Nova).to receive(:create_k8s_job)
  end

  it "creates a worker" do
    expect { described_class.new.perform(task.id) }
      .to change { Worker.count }.by(1)
  end

  it "creates a worker with an access token" do
    described_class.new.perform(task.id)
    expect(task.reload.worker.access_token).to be_present
  end

  it "creates a worker with a name containing the repo name" do
    described_class.new.perform(task.id)
    expect(task.reload.worker.name).to include(test_suite_run.repository.name.downcase)
  end

  it "creates a worker with a name containing the short task id" do
    described_class.new.perform(task.id)
    expect(task.reload.worker.name).to include(task.id[0..7])
  end

  it "creates a WorkerAssignment linking the task and worker" do
    expect { described_class.new.perform(task.id) }
      .to change { WorkerAssignment.count }.by(1)
  end

  it "creates a runner_requested task event" do
    expect { described_class.new.perform(task.id) }
      .to change { task.task_events.where(type: "runner_requested").count }.by(1)
  end

  it "calls Nova.create_k8s_job with the worker and task" do
    expect(Nova).to receive(:create_k8s_job) do |worker, t|
      expect(worker).to be_a(Worker)
      expect(t).to eq(task)
    end

    described_class.new.perform(task.id)
  end
end
