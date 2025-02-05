module Admin
  class UserImpersonationsController < ApplicationController
    def create
      authorize :user_impersonation

      user = User.find(params[:user_id])
      sign_in(:user, user)
      redirect_to user.projects.first
    end
  end
end
