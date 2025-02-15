module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!
      before_action :authenticate_api_user!

      def authenticate_api_user!
        authenticate_or_request_with_http_basic do |user_id, api_token|
          @current_user = User.find_by(id: user_id)
          @current_user && @current_user.api_token == api_token
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
