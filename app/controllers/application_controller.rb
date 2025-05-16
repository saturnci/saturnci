class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user_or_404!, unless: :devise_controller?
  before_action :can_hit_github_api?, if: :user_signed_in?
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

  def can_hit_github_api?
    begin
      current_user.github_client.user
    rescue Octokit::Unauthorized
      sign_out current_user
      redirect_to new_user_session_path
    end
  end
end
