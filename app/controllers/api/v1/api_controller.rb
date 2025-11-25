module API
  module V1
    class APIController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :authenticate_user_or_404!
      before_action :authenticate_api_user!

      def authenticate_api_user!
        authenticate_or_request_with_http_basic do |user_id, api_token|
          access_token = AccessToken.find_by(value: api_token)

          if access_token.present?
            @current_user = User.joins(:personal_access_tokens).find_by(
              id: user_id,
              personal_access_tokens: { access_token: access_token }
            )
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
