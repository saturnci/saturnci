module Admin
  class AdminController < ApplicationController
    def index
      head :unauthorized unless current_user.super_admin?
    end
  end
end
