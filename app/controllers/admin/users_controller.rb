module Admin
  class UsersController < ApplicationController
    def index
      @users = User.order("created_at desc")
    end
  end
end
