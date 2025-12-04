require "rails_helper"

describe WorkerPool, "pruning" do
  before do
    allow(Worker).to receive(:create_vm)
    allow_any_instance_of(Worker).to receive(:deprovision)
    allow(Dispatcher).to receive(:log)
  end

  let!(:c) { TestRunOrchestrationCheck.new }

  before do
    allow(WorkerPool).to receive(:target_size).and_return(4)
  end

  context "there are 6 unassigned workers" do
    it "deletes an unassigned worker" do
      create_list(:worker, 5)
      worker_pool = WorkerPool.instance
      expect { worker_pool.prune }.to change(Worker, :count).by(-1)
    end
  end

  context "there are 4 unassigned workers and 2 more in error" do
    it "deletes the 2 errored workers" do
      create_list(:worker, 4)

      2.times do
        worker = create(:worker)
        worker.worker_events.create!(type: :error)
      end

      expect { Dispatcher.check(c) }.to change(Worker, :count).by(-2)
    end
  end

  context "there's an unassigned worker that's more than an hour old" do
    it "deletes it" do
      worker = create(:worker)

      travel_to(2.hours.from_now) do
        expect { Dispatcher.check }.to change { Worker.exists?(worker.id) }.to(false)
      end
    end
  end

  context "there's an assigned worker that's more than an hour old" do
    it "does not delete it" do
      worker = create(:worker_assignment).worker

      travel_to(2.hours.from_now) do
        expect { Dispatcher.check(c) }.to_not change { Worker.exists?(worker.id) }
      end
    end
  end

  context "there's an assigned worker that's more than a day old" do
    it "deletes it" do
      worker = create(:worker_assignment).worker

      travel_to(2.days.from_now) do
        expect { Dispatcher.check(c) }.to change { Worker.exists?(worker.id) }.from(true).to(false)
      end
    end
  end

end
