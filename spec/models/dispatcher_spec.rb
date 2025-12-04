require "rails_helper"

describe Dispatcher do
  before do
    allow(Worker).to receive(:create_vm)
    allow_any_instance_of(Worker).to receive(:deprovision)
    allow(Dispatcher).to receive(:log)
  end

  describe "fleet" do
    let!(:c) { TestRunOrchestrationCheck.new }

    before do
      allow(WorkerPool).to receive(:target_size).and_return(4)
    end

    context "there are 3 workers" do
      it "creates 1 worker" do
        create_list(:worker, 3)
        expect { Dispatcher.check(c) }.to change(Worker, :count).by(1)
      end
    end

    context "there are 4 workers" do
      it "does not create a worker" do
        create_list(:worker, 4)
        expect { Dispatcher.check(c) }.to_not change(Worker, :count)
      end
    end

    context "there are 5 workers but 4 of them are assigned" do
      it "creates 4 - 1 = 3 workers" do
        create_list(:worker_assignment, 4)
        create(:worker)
        expect { Dispatcher.check(c) }.to change(Worker, :count).by(3)
      end
    end
  end

  context "run already finished" do
    let!(:run) { create(:run, :passed) }

    before do
      allow(Worker).to receive(:available).and_return([create(:worker)])
    end

    it "does not add an assignment" do
      expect { Dispatcher.check }.to_not change(WorkerAssignment, :count)
    end
  end

  context "an assigned test runner hasn't started running within 30 seconds" do
    let!(:worker_assignment) { create(:worker_assignment) }

    it "deletes the assignment" do
      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(WorkerAssignment.exists?(worker_assignment.id)).to be false
      end
    end

    it "puts the test runner in error status" do
      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(worker_assignment.worker.status).to eq("Error")
      end
    end

    context "run is more than a day old" do
      before do
        allow(Dispatcher).to receive(:delete_workers)
      end

      it "does not delete the assignment" do
        travel_to(25.hours.from_now) do
          Dispatcher.check
          expect(WorkerAssignment.exists?(worker_assignment.id)).to be true
        end
      end
    end
  end

  context "an assigned test runner HAS started running within 30 seconds" do
    it "does not delete the assignment" do
      worker_assignment = create(:worker_assignment)

      create(
        :worker_event,
        worker: worker_assignment.worker,
        type: :assignment_acknowledged
      )

      travel_to(60.seconds.from_now) do
        Dispatcher.check
        expect(WorkerAssignment.exists?(worker_assignment.id)).to be true
      end
    end
  end

  context "a run has already been executed but its assignment was deleted" do
    it "does not reassign the run" do
      completed_run = create(:run, :passed)

      worker_assignment = create(:worker_assignment, run: completed_run)
      worker_assignment.destroy

      worker = create(:worker)
      allow(Worker).to receive(:available).and_return([worker])

      expect { Dispatcher.check }.to_not change(WorkerAssignment, :count)
    end
  end
end
