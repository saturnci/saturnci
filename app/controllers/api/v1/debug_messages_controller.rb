module API
  module V1
    class DebugMessagesController < APIController
      def create
        begin
          Rails.logger.info(request.body.read)
          skip_authorization
        rescue StandardError => e
          render(json: { error: e.message }, status: :bad_request)
          return
        end

        head :ok
      end
    end
  end
end
