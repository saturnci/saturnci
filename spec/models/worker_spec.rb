require "rails_helper"

describe Worker do
  before do
    admin_user = double
    allow(admin_user).to receive(:id).and_return(1)
    allow(admin_user).to receive(:api_token).and_return("token")
    allow(User).to receive(:find_by).and_return(admin_user)
  end

  describe "status" do
    context "ready" do
      it "returns ready" do
        worker = create(:worker)
        worker.worker_events.create!(name: "ready_signal_received")
        expect(worker.status).to eq("Available")
      end
    end
  end

  describe "#to_json" do
    it "includes the task's commit message" do
      task = create(:task) do |t|
        t.test_suite_run.update!(commit_message: "Add stuff.")
      end

      create(:worker, task:)

      expect(JSON.parse(task.worker.to_json)["commit_message"]).to eq("Add stuff.")
    end
  end
end
