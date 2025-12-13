require "rails_helper"

RSpec.describe TaskEventsComponent, type: :component do
  describe "#event_list" do
    context "task has no worker" do
      let!(:task) { create(:task) }

      it "returns an empty event list" do
        component = TaskEventsComponent.new(task: task)
        expect(component.event_list.events).to eq([])
      end
    end

    context "task has a worker with events" do
      let!(:task) { create(:task) }
      let!(:worker) { create(:worker, task: task) }
      let!(:event_1) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:00")) }
      let!(:event_2) { create(:worker_event, worker: worker, created_at: Time.zone.parse("2025-01-01 12:00:10")) }

      it "returns an event list with the worker events" do
        component = TaskEventsComponent.new(task: task)
        expect(component.event_list.events).to eq([event_1, event_2])
      end
    end
  end
end
