class TaskEventsComponent < ViewComponent::Base
  def initialize(task:)
    @task = task
  end

  def events
    event_list.events
  end

  def interval_since_previous_event(_event, index)
    event_list.duration_since_previous(index)
  end

  private

  def event_list
    @event_list ||= TaskEventList.new(@task.worker&.worker_events&.order(:created_at) || [])
  end
end
