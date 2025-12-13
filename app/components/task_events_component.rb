class TaskEventsComponent < ViewComponent::Base
  def initialize(task:)
    @task = task
  end

  def events
    @task.worker&.worker_events&.order(:created_at) || []
  end

  def interval_since_previous_event(event, index)
    return nil if index.zero?

    (event.created_at - events[index - 1].created_at).round(2)
  end
end
