class RepositoriesController < ApplicationController
  skip_before_action :authenticate_user_or_404!, only: :index

  def index
    if user_signed_in?
      if current_user.email.present?
        @repositories = current_user.repositories
        authorize @repositories
      else
        skip_authorization
        redirect_to new_user_email_path
      end
    else
      skip_authorization
      redirect_to new_user_session_path
    end
  end
end
