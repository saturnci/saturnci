module Admin
  class UserImpersonationsController < ApplicationController
    def create
      authorize :user_impersonation

      user = User.find(params[:user_id])
      sign_in(:user, user)

      if user.projects.any?
        redirect_to user.projects.first
      else
        redirect_to github_accounts_path
      end
    end
  end
end
