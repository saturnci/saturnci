require "rails_helper"

describe TaskEventList do
  describe "#interval_since_previous_event" do
    let!(:task) { create(:task) }
    let!(:worker) { create(:worker, task:) }
    let!(:event1) { create(:worker_event, worker:, created_at: Time.zone.parse("2025-01-01 12:00:00")) }
    let!(:event2) { create(:worker_event, worker:, created_at: Time.zone.parse("2025-01-01 12:00:10")) }
    let!(:task_event_list) { TaskEventList.new(task) }

    context "when index is 0" do
      it "returns nil" do
        expect(task_event_list.interval_since_previous_event(0)).to be_nil
      end
    end

    context "when index is greater than 0" do
      it "returns the seconds between the event and the previous event" do
        expect(task_event_list.interval_since_previous_event(1)).to eq("10.00")
      end
    end

    context "precision" do
      let!(:event1) { create(:worker_event, worker:, created_at: Time.zone.parse("2025-01-01 12:00:00.0")) }
      let!(:event2) { create(:worker_event, worker:, created_at: Time.zone.parse("2025-01-01 12:00:08.2")) }

      it "returns a value with two decimal places" do
        expect(task_event_list.interval_since_previous_event(1)).to eq("8.20")
      end
    end
  end

  describe "#total_runtime" do
    let!(:task) { create(:task) }
    let!(:worker) { create(:worker, task:) }

    context "when worker_started event is missing" do
      let!(:task_finished) { create(:worker_event, worker:, name: "task_finished", created_at: Time.zone.parse("2025-01-01 12:00:25")) }

      it "returns nil" do
        expect(TaskEventList.new(task).total_runtime).to be_nil
      end
    end

    context "when task_finished event is missing" do
      let!(:worker_started) { create(:worker_event, worker:, name: "worker_started", created_at: Time.zone.parse("2025-01-01 12:00:00")) }

      it "returns nil" do
        expect(TaskEventList.new(task).total_runtime).to be_nil
      end
    end

    context "when both worker_started and task_finished events exist" do
      let!(:worker_started) { create(:worker_event, worker:, name: "worker_started", created_at: Time.zone.parse("2025-01-01 12:00:00")) }
      let!(:task_finished) { create(:worker_event, worker:, name: "task_finished", created_at: Time.zone.parse("2025-01-01 12:00:25.5")) }

      it "returns the time from worker_started to task_finished" do
        expect(TaskEventList.new(task).total_runtime).to eq("25.50")
      end
    end
  end
end
