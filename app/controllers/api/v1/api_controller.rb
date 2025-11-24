module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!
      before_action :authenticate_api_user!

      def authenticate_api_user!
        authenticate_or_request_with_http_basic do |user_id, api_token|
          personal_access_token = PersonalAccessToken.find_by(value: api_token)

          if personal_access_token.present?
            @current_user = personal_access_token.user
          else
            # legacy token
            @current_user = User.find_by(id: user_id, api_token: api_token)
          end

          @current_user.present?
        end
      end

      def current_user
        @current_user
      end
    end
  end
end
