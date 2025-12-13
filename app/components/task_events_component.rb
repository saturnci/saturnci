class TaskEventsComponent < ViewComponent::Base
  attr_reader :event_list

  def initialize(task:)
    @event_list = TaskEventList.new(task.worker&.worker_events&.order(:created_at) || [])
  end
end
