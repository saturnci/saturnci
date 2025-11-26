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
          @current_user = User.joins(:access_tokens).find_by(
            id: user_id,
            access_tokens: { value: api_token }
          )
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
