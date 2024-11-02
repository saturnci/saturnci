module Admin
  class UserImpersonationsController < ApplicationController
    def create
      head :unauthorized and return unless current_user.super_admin?

      @user = User.find(params[:user_id])
      redirect_to @user.projects.first
    end
  end
end
