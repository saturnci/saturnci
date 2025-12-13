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
        expect(task_event_list.interval_since_previous_event(1)).to eq(10.0)
      end
    end
  end
end
