class TaskEventList
  attr_reader :events

  def initialize(task)
    @events = (task.worker&.worker_events&.order(:created_at) || []).to_a
  end

  def interval_since_previous_event(index)
    return nil if index.zero?

    format("%.2f", @events[index].created_at - @events[index - 1].created_at)
  end

  def percentage_of_total(index)
    return nil if index.zero?
    return nil unless total_runtime_seconds

    interval = @events[index].created_at - @events[index - 1].created_at
    format("%.2f", (interval / total_runtime_seconds) * 100)
  end

  def total_runtime
    return nil unless total_runtime_seconds

    format("%.2f", total_runtime_seconds)
  end

  private

  def total_runtime_seconds
    return @total_runtime_seconds if defined?(@total_runtime_seconds)

    worker_started = @events.find { |e| e.name == "worker_started" }
    task_finished = @events.find { |e| e.name == "task_finished" }

    @total_runtime_seconds = if worker_started && task_finished
                               task_finished.created_at - worker_started.created_at
                             end
  end
end
