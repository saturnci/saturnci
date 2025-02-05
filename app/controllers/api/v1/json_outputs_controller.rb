require "base64"

module API
  module V1
    class JSONOutputsController < APIController
      def create
        run = Run.find(params[:run_id])
        run.update!(json_output: Base64.decode64(request.body.read))

        head :ok
      end
    end
  end
end
