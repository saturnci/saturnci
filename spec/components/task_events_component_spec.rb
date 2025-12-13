require "rails_helper"

RSpec.describe TaskEventsComponent, type: :component do
  describe "#events" do
    context "task has no worker" do
      let!(:task) { create(:task) }

      it "returns an empty array" do
        component = TaskEventsComponent.new(task: task)
        expect(component.events).to eq([])
      end
    end

    context "task has a worker with no events" do
      let!(:task) { create(:task) }
      let!(:worker) { create(:worker, task: task) }

      it "returns an empty array" do
        component = TaskEventsComponent.new(task: task)
        expect(component.events).to eq([])
      end
    end

    context "task has a worker with events" do
      let!(:task) { create(:task) }
      let!(:worker) { create(:worker, task: task) }
      let!(:event_1) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:00")) }
      let!(:event_2) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:10")) }

      it "returns the events ordered by created_at" do
        component = TaskEventsComponent.new(task: task)
        expect(component.events).to eq([event_1, event_2])
      end
    end
  end

  describe "#interval_since_previous_event" do
    let!(:task) { create(:task) }
    let!(:worker) { create(:worker, task: task) }
    let!(:event_1) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:00")) }
    let!(:event_2) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:10")) }

    context "first event (index 0)" do
      it "returns nil" do
        component = TaskEventsComponent.new(task: task)
        expect(component.interval_since_previous_event(event_1, 0)).to be_nil
      end
    end

    context "subsequent event" do
      it "returns the interval in seconds" do
        component = TaskEventsComponent.new(task: task)
        expect(component.interval_since_previous_event(event_2, 1)).to eq(10.0)
      end
    end
  end
end
