module API
  module V1
    class CompleteSyslogsController < APIController
      def create
        begin
          run = Run.find(params[:run_id])
          authorize run, :update?

          request.body.rewind
          run.update!(complete_syslog: request.body.read)
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
