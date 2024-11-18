module API
  module V1
    class JobMachinesController < APIController
      def destroy
        run = Run.find(params[:job_id])
        run.delete_runner
        head :ok
      end
    end
  end
end
