module API
  module V1
    class RunnersController < APIController
      def destroy
        run = Run.find(params[:run_id])
        run.delete_runner if run.terminate_on_completion
        head :ok
      end
    end
  end
end
