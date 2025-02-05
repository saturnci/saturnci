module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!
      before_action :authenticate_api_user!
      skip_after_action :verify_authorized

      def authenticate_api_user!
        authenticate_or_request_with_http_basic do |user_id, api_token|
          user = User.find_by(id: user_id)
          user && user.api_token == api_token
        end
      end
    end
  end
end
