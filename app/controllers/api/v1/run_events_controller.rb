module API
  module V1
    class RunEventsController < APIController
      def create
        run = Run.find(params[:run_id])
        run.run_events.create!(type: params[:type])
        head :ok
      end
    end
  end
end
