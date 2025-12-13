class EventList
  attr_reader :events

  def initialize(events)
    @events = events
  end

  def duration_since_previous(index)
    return nil if index.zero?

    (@events[index].created_at - @events[index - 1].created_at).round(2)
  end
end
