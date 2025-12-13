require "rails_helper"

describe TaskEventList do
  describe "#duration_since_previous" do
    let!(:event1) { create(:worker_event, created_at: Time.zone.parse("2025-01-01 12:00:00")) }
    let!(:event2) { create(:worker_event, created_at: Time.zone.parse("2025-01-01 12:00:10")) }
    let!(:event_list) { TaskEventList.new([event1, event2]) }

    context "when index is 0" do
      it "returns nil" do
        expect(event_list.duration_since_previous(0)).to be_nil
      end
    end

    context "when index is greater than 0" do
      it "returns the seconds between the event and the previous event" do
        expect(event_list.duration_since_previous(1)).to eq(10.0)
      end
    end
  end
end
