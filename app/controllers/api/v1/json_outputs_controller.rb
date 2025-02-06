module API
  module V1
    class JSONOutputsController < APIController
      def create
        run = Run.find(params[:run_id])
        request.body.rewind
        run.update!(json_output: request.body.read)

        head :ok
      end
    end
  end
end
