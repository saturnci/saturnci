module Admin
  class UsersController < ApplicationController
    def index
      @users = User.order("created_at desc")
      authorize :admin, :index?
    end
  end
end
