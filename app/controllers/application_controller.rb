class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :authenticate_user_or_404!, unless: :devise_controller?
  before_action :set_current_user_impersonating, if: :user_signed_in?
  before_action :check_github_api_access, if: -> { user_signed_in? && !current_user.impersonating? }

  after_action :verify_authorized, unless: :devise_controller?

  private

  def authenticate_user_or_404!
    unless user_signed_in?
      head :not_found
    end
  end

  def user_not_authorized
    head :not_found
  end

  def check_github_api_access
    return if current_user.can_hit_github_api?
    return if current_user.super_admin?

    sign_out current_user
    redirect_to new_user_session_path
  end

  def set_current_user_impersonating
    current_user.impersonating = session[:impersonating]
  end
end
