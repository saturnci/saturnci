require "rails_helper"

describe "Assigning unassigned runs" do
  context "a worker is available" do
    it "assigns a run to that worker" do
      worker = create(:worker)
      run = create(:run)

      allow(Worker).to receive(:available).and_return([worker])
      allow(Worker).to receive(:create_vm)

      expect {
        Dispatcher.check
      }.to change { run.reload.worker&.id }.from(nil).to(worker.id)
    end
  end
end
