class TaskEventList
  attr_reader :events

  def initialize(task)
    @events = task.worker&.worker_events&.order(:created_at) || []
  end

  def interval_since_previous_event(index)
    return nil if index.zero?

    (@events[index].created_at - @events[index - 1].created_at).round(2)
  end
end
