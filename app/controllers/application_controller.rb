class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user_or_404!, unless: :devise_controller?
  after_action :verify_authorized, unless: :devise_controller?
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_user_or_404!
    unless user_signed_in?
      head :not_found
    end
  end

  def user_not_authorized
    head :not_found
  end
end
