module API
  module V1
    class TasksController < APIController
      def show
        task = Task.find(params[:id])
        authorize task

        task_event_list = TaskEventList.new(task)

        render json: {
          events: task_event_list.events.each_with_index.map do |event, index|
            {
              name: event.name,
              timestamp: event.created_at,
              notes: event.notes,
              duration_since_previous: task_event_list.duration_since_previous(index)
            }
          end
        }
      end
    end
  end
end
