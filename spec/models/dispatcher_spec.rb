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

end
