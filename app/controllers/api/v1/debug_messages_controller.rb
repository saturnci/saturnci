module API
  module V1
    class DebugMessagesController < APIController
      def create
        Rails.logger.info(request.body.read)
        head :ok
      end
    end
  end
end
