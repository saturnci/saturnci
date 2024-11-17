module API
  module V1
    class JobEventsController < APIController
      def create
        run = Run.find(params[:job_id])
        run.run_events.create!(type: params[:type])
        head :ok
      end
    end
  end
end
