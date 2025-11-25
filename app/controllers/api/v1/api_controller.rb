module API
  module V1
    class APIController < ActionController::Base
      include Pundit::Authorization
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!
      after_action :verify_authorized

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

      def user_not_authorized
        head :not_found
      end
    end
  end
end
