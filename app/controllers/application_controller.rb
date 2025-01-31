class ApplicationController < ActionController::Base
  before_action :authenticate_user_or_404!
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_user_or_404!
    unless user_signed_in?
      head :not_found
    end
  end

  def user_not_authorized
    render status: :not_found
  end
end
