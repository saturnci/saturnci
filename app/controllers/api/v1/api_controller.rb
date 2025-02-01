module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!
      before_action :authenticate_api_user!

      def authenticate_api_user!
        authenticate_or_request_with_http_basic do |run_id, api_token|
          run = Run.find_by(id: run_id)
          run && run.api_token == api_token
        end
      end
    end
  end
end
