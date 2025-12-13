module API
  module V1
    class TasksController < APIController
      def show
        task = Task.find(params[:id])
        authorize task

        task_event_list = TaskEventList.new(task)

        render json: {
          total_runtime: task_event_list.total_runtime,
          system_logs: task.system_logs,
          events: task_event_list.events.each_with_index.map do |event, index|
            {
              name: event.name,
              timestamp: event.created_at,
              notes: event.notes,
              interval_since_previous_event: task_event_list.interval_since_previous_event(index),
              percentage_of_total: task_event_list.percentage_of_total(index)
            }
          end
        }
      end
    end
  end
end
