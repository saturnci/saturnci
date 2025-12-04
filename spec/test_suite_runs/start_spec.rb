require "rails_helper"

describe "Starting test suite run" do
  let!(:project) { create(:project, concurrency: 2) }
  let!(:test_suite_run) { create(:build, project:) }

  context "there are available workers" do
    before do
      allow(Worker).to receive(:available).and_return(create_list(:worker, 2))
      allow(Worker).to receive(:create_vm)
    end

    it "makes the assignments" do
      expect do
        test_suite_run.start!
        Dispatcher.check
      end.to change(WorkerAssignment, :count).by(2)
    end
  end

  context "there are available workers" do
    before do
      2.times do
        create(:worker) do |worker|
          worker.worker_events.create!(type: :ready_signal_received)
        end
      end
    end

    it "does not add workers" do
      expect { test_suite_run.start! }
        .not_to change(Worker, :count)
    end
  end
end
