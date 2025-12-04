module API
  module V1
    module WorkerAgents
      class WorkerAgentsAPIController < ActionController::Base
        skip_before_action :verify_authenticity_token
        before_action :authenticate_worker!

        def authenticate_worker!
          authenticate_or_request_with_http_basic do |worker_id, api_token|
            access_token = AccessToken.find_by(value: api_token)
            @current_worker = Worker.find_by(id: worker_id, access_token: access_token) if access_token.present?
            @current_worker.present?
          end
        end
      end
    end
  end
end
