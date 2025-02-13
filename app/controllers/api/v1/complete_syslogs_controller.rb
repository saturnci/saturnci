module API
  module V1
    class CompleteSyslogsController < APIController
      def create
        run = Run.find(params[:run_id])
        request.body.rewind
        run.update!(complete_syslog: request.body.read)

        head :ok
      end
    end
  end
end
